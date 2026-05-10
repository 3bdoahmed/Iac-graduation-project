import boto3
import os

from datetime import datetime
from decimal import Decimal

dynamodb = boto3.resource('dynamodb', region_name="eu-west-3")

solar_table = dynamodb.Table(os.environ['SOLAR_TABLE'])
battery_table = dynamodb.Table(os.environ['BATTERY_TABLE'])
summary_table = dynamodb.Table(os.environ['SUMMARY_TABLE'])


def to_float(value):
    try:
        return float(value or 0)
    except:
        return 0


def lambda_handler(event, context):

    # =========================
    # SOLAR DATA
    # =========================
    solar_response = solar_table.scan()

    total_ACpower = 0
    total_ACcurrent = 0
    total_ACVoltage = 0

    total_DCpower = 0
    total_DCcurrent = 0
    total_DCVoltage = 0

    for item in solar_response.get('Items', []):

        total_ACpower += to_float(item.get('AC_Power'))
        total_ACcurrent += to_float(item.get('AC_Current'))
        total_ACVoltage += to_float(item.get('AC_Voltage'))

        total_DCpower += to_float(item.get('DC_Power'))
        total_DCcurrent += to_float(item.get('DC_Current'))
        total_DCVoltage += to_float(item.get('DC_Voltage'))

    # =========================
    # BATTERY DATA
    # =========================
    battery_response = battery_table.scan()

    total_charge = 0
    count = 0
    low_battery = 0
    full_battery = 0

    for item in battery_response.get('Items', []):

        charge = to_float(item.get('AverageCharge'))

        total_charge += charge
        count += 1

        if charge < 30:
            low_battery += 1

        elif charge >= 90:
            full_battery += 1

    avg_charge = total_charge / count if count > 0 else 0

    # =========================
    # SYSTEM HEALTH
    # =========================
    if avg_charge < 30 or low_battery > 3:
        battery_health = "CRITICAL"

    elif avg_charge < 60:
        battery_health = "WARNING"

    else:
        battery_health = "OK"

    # =========================
    # SAVE DATA
    # =========================
    timestamp = datetime.utcnow().isoformat()

    summary_table.put_item(
        Item={
            "summaryID": "Main_SYSTEM",
            "Timestamp": timestamp,
            "Total_AC_PanelPower": Decimal(str(total_ACpower)),
            "Total_AC_PanelCurrent": Decimal(str(total_ACcurrent)),
            "Total_AC_PanelVoltage": Decimal(str(total_ACVoltage)),
            "Total_DC_PanelPower": Decimal(str(total_DCpower)),
            "Total_DC_PanelCurrent": Decimal(str(total_DCcurrent)),
            "Total_DC_PanelVoltage": Decimal(str(total_DCVoltage)),
            "TotalBatteryCharge": Decimal(str(round(avg_charge, 2))),
            "Low_Battery_Count": low_battery,
            "Fully_Charged_Count": full_battery,
            "BATTERY_Health": battery_health
        }
    )

    return {
        "statusCode": 200,
        "body": "New system snapshot saved successfully"
    }