provider "pagerduty" {
  token = "${var.pagerduty_token}"
}

resource "pagerduty_team" "default" {
  name = "${var.team_name} Team"
  description = ""
}

resource "pagerduty_schedule" "primary" {
  name = "${pagerduty_team.default.name} Schedule - Primary"
  time_zone = "Asia/Tokyo"
  
  layer {
    name = "Layer 1"
    start = "${replace(timestamp(), "Z", "+0900")}"
    rotation_virtual_start = "${replace(timestamp(), "Z", "+09:00")}"
    rotation_turn_length_seconds = 604800
    users = [""]
  }
}

resource "pagerduty_schedule" "secondary" {
  name = "${pagerduty_team.default.name} Schedule - Secondary"
  time_zone = "Asia/Tokyo"
  
  layer {
    name = "Layer 1"
    start = "${replace(timestamp(), "Z", "+0900")}"
    rotation_virtual_start = "${replace(timestamp(), "Z", "+09:00")}"
    rotation_turn_length_seconds = 604800
    users = [""]
  }
}

resource "pagerduty_schedule" "tertiary" {
  name = "${pagerduty_team.default.name} Schedule - Tertiary"
  time_zone = "Asia/Tokyo"
  
  layer {
    name = "Layer 1"
    start = "${replace(timestamp(), "Z", "+0900")}"
    rotation_virtual_start = "${replace(timestamp(), "Z", "+09:00")}"
    rotation_turn_length_seconds = 604800
    users = [""]
  }
}

resource "pagerduty_escalation_policy" "default" {
  name = "${pagerduty_team.default.name} - Default Policy"
  teams = ["${pagerduty_team.default.id}"]

  num_loops = 3

  rule {
    escalation_delay_in_minutes = 3
    target {
      type = "schedule_reference"
      id = "${pagerduty_schedule.primary.id}"
    }
  }

  rule {
    escalation_delay_in_minutes = 3
    target {
      type = "schedule_reference"
      id = "${pagerduty_schedule.secondary.id}"
    }
  }

  rule {
    escalation_delay_in_minutes = 5
    target {
      type = "schedule_reference"
      id = "${pagerduty_schedule.tertiary.id}"
    }
  }
}

resource "pagerduty_service" "default" {
  name = ""
  auto_resolve_timeout = 14400 # 4hour
  acknowledgement_timeout = 1800
  escalation_policy = "${pagerduty_escalation_policy.default.id}"
  alert_creation = "create_alerts_and_incidents"
}

data "pagerduty_vendor" "cloudwatch" {
  name = "Amazon CloudWatch"
}

data "pagerduty_vendor" "datadog" {
  name = "Datadog"
}

data "pagerduty_vendor" "papertrail" {
  name = "Papertrail"
}

data "pagerduty_vendor" "mackerel" {
  name = "mackerel"
}

resource "pagerduty_service_integration" "cloudwatch" {
  name = "${data.pagerduty_vendor.cloudwatch.name}"
  service = "${pagerduty_service.default.id}"
  vendor = "${data.pagerduty_vendor.cloudwatch.id}"
}

resource "pagerduty_service_integration" "datadog" {
  name = "${data.pagerduty_vendor.datadog.name}"
  service = "${pagerduty_service.default.id}"
  vendor = "${data.pagerduty_vendor.datadog.id}"
}

resource "pagerduty_service_integration" "papertrail" {
  name = "${data.pagerduty_vendor.papertrail.name}"
  service = "${pagerduty_service.default.id}"
  vendor = "${data.pagerduty_vendor.papertrail.id}"
}

resource "pagerduty_service_integration" "mackerel" {
  name = "${data.pagerduty_vendor.mackerel.name}"
  service = "${pagerduty_service.default.id}"
  vendor = "${data.pagerduty_vendor.mackerel.id}"
}
