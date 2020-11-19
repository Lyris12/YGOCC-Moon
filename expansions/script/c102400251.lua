--created & coded by Lyris, art from Cardfight!! Vanguard's "Mothership Intelligence"
--アーマリン・インテリジェンス・コマーンダー
local s,id=GetID()
function s.initial_effect(c)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_MZONE)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCondition(s.con)
	e1:SetCategory(CATEGORY_REMOVE+CATEGORY_DESTROY)
	e1:SetHintTiming(TIMING_DAMAGE_STEP)
	e1:SetTarget(s.tg)
	e1:SetOperation(s.op)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_DESTROYED)
	e2:SetOperation(s.regop)
	c:RegisterEffect(e2)
end
function s.con(e,tp)
	local a=Duel.GetAttacker()
	if not a then return false end
	if a:IsControler(1-tp) then a=Duel.GetAttackTarget() end
	return a and a~=e:GetHandler() and a:IsSetCard(0xa6c) and a:IsRelateToBattle()
		and Duel.GetCurrentPhase()==PHASE_DAMAGE and not Duel.IsDamageCalculated()
end
function s.tg(e,tp,eg,ep,ev,re,r,rp,chk)
	local a=Duel.GetAttacker()
	if a:IsControler(1-tp) then a=Duel.GetAttackTarget() end
	a=a:GetBattleTarget()
	if chk==0 then return a and a:IsAbleToRemove() end
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,a,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,e:GetHandler(),1,0,0)
end
function s.op(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local a=Duel.GetAttacker()
	if a:IsControler(1-tp) then a=Duel.GetAttackTarget() end
	a=a:GetBattleTarget()
	if not a:IsRelateToBattle() or Duel.Remove(a,POS_FACEUP,REASON_EFFECT+REASON_TEMPORARY)==0
		or a:IsType(TYPE_TOKEN) then return end
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_PHASE+PHASE_END)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetCountLimit(1)
	e1:SetOperation(function() Duel.ReturnToField(a) end)
	Duel.RegisterEffect(e1,tp)
	Duel.BreakEffect()
	Duel.Destroy(c,REASON_EFFECT)
end
function s.regop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_PRE_BATTLE_DAMAGE)
	e1:SetOperation(function(e,tp,eg,ep,ev)
		local a=Duel.GetAttacker()
		if a:IsControler(1-tp) then a=Duel.GetAttackTarget() end
		if not a then return end
		if a:IsSetCard(0xa6c) and ep~=tp and Duel.SelectEffectYesNo(tp,c) then
			Duel.ChangeBattleDamage(1-tp,ev*2)
			e1:Reset()
		end
	end)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
end
