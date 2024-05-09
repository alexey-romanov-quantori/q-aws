from django.contrib import admin
from django.db import transaction

from computation.models import Computation, start_computation_task


@admin.register(Computation)
class ComputationAdmin(admin.ModelAdmin):
    list_display = ('start_date', 'end_date', 'status')
    # readonly_fields = (
    #     'start_date', 'end_date', 'status', 'celery_task_id', 'unique_identifier', 'result_file', 'owner')
    #
    # fieldsets = (
    #     ('Metadata', {
    #        'fields': (('start_date', 'end_date', 'status'), ('celery_task_id', 'unique_identifier'))
    #     }),
    #     ('Computation parameters', {
    #        'fields': ('g_u_wobble', 'word_length', 'off_targets_transcripts_threshold', 'cut_off')
    #     }),
    #     ('Permanent input', {
    #         'fields': (('relevant_transcriptomes_file', 'micro_rna_seeds_file'), 'matrix_of_penalty_scores_file'),
    #     }),
    #     ('Users input', {
    #         'fields': (
    #             'lead_on_target_transcript_file', 'chemical_modification_pattern_file'),
    #     }),
    #     ('Results', {
    #         'fields': ('result_file', 'other_computation_results_file'),
    #     }),
    # )

    def save_model(self, request, obj, form, change):
        """ Run computation on saving model via save button in admin panel """
        with transaction.atomic():
            obj.owner = request.user
            super().save_model(request, obj, form, change)
            start_computation_task.delay(obj.id)
            obj.status = obj.STATUS_PENDING
            obj.save()
