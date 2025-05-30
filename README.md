"text": "🚨 **High CPU Utilization Alert Triggered**\n\n- **Instance Name**: $${metric.labels.instance_name}\n- **Instance ID**: $${resource.labels.instance_id}\n- **Zone**: $${resource.labels.zone}\n- **Project ID**: $${resource.labels.project_id}\n- **Metric Type**: $${metric.type}\n- **Condition Name**: $${condition.name}\n- **Metric Display Name**: $${metric.display_name}\n\n⚠️ Please investigate the affected VM immediately.",



How to Increase the Suppressed Alert Threshold in xMatters

1️⃣ Log in to xMatters Admin Console

Make sure you have admin access.


2️⃣ Go to the Flood Control Settings

Navigate to the Messaging or Flood Control section (varies slightly by version).

If you’re in the xMatters classic interface, look for Flood Control under Company Settings.


3️⃣ Find the Rule for the Alert Group

Look for the rule that applies to your group: et-finex-bff-peak-it-EMAIL.


4️⃣ Adjust the Threshold

You’ll see a setting like:
**“Limit to X
