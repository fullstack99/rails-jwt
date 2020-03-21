require 'google/apis/analyticsreporting_v4'
class GoogleAnalytics
    def getCampaignData(token, view_id, source, medium, campaign)
        service = Google::Apis::AnalyticsreportingV4::AnalyticsReportingService.new
            credentials = Google::Auth::ServiceAccountCredentials.make_creds(
                json_key_io: File.open(token),
                scope: 'https://www.googleapis.com/auth/analytics.readonly'
        )
        service.authorization = credentials
        $google_client = service

        date_range = Google::Apis::AnalyticsreportingV4::DateRange.new(
            start_date: "30daysAgo",
            end_date: "yesterday"
        )
        metric_users = Google::Apis::AnalyticsreportingV4::Metric.new(
            expression: "ga:users"
        )
        metric_total_conversions = Google::Apis::AnalyticsreportingV4::Metric.new(
            expression: "ga:goalConversionRateAll"
        )
        metric_total_product_boughts = Google::Apis::AnalyticsreportingV4::Metric.new(
            expression: "ga:productCheckouts"
        )
        metric_avg_time_on_site = Google::Apis::AnalyticsreportingV4::Metric.new(
            expression: "ga:avgTimeOnPage"
        )
        metric_pageviews = Google::Apis::AnalyticsreportingV4::Metric.new(
            expression: "ga:pageviews"
        )
        dimension_source = Google::Apis::AnalyticsreportingV4::Dimension.new(
            name: "ga:source"
        )
        dimension_medium = Google::Apis::AnalyticsreportingV4::Dimension.new(
            name: "ga:medium"
        )
        dimension_campaign = Google::Apis::AnalyticsreportingV4::Dimension.new(
            name: "ga:campaign"
        )
        report_request = Google::Apis::AnalyticsreportingV4::ReportRequest.new(
            view_id: view_id,
            metrics: [metric_users, metric_total_conversions, metric_total_product_boughts, metric_avg_time_on_site, metric_pageviews],
            dimensions: [dimension_source, dimension_medium, dimension_campaign],
            date_ranges: [date_range],
            filters_expression: "ga:source==#{source};ga:medium==#{medium};ga:campaign==#{campaign}"
        )
        request = Google::Apis::AnalyticsreportingV4::GetReportsRequest.new(
            { report_requests: [report_request] }
        )
        response = $google_client.batch_get_reports(request)
        response.reports
    end
end
describe GoogleAnalytics do
    context "When testing the GoogleAnalytics class" do
    it "should: have the vaild data" do

        ga = GoogleAnalytics.new
        data = ga.getCampaignData('credential/service_account_cred.json', '213241790', 'm.facebook.com', 'referral', '(not set)')
        expect(data).not_to be_empty
        puts data.inspect
        end
        #data.each do |key, value|
        #    puts "data[#{key}] = #{value.inspect}"
        #    end
        #end
    end
end