--created & coded by Lyris, art from Cardfight!! Vanguard's "Mothership Intelligence"
--アーマリン・インテリジェンス・コマーンダー
local s,id,o=GetID()
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
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	local g=Duel.SelectMatchingCard(tp,aux.AND(Card.IsFaceup,Card.IsSetCard),tp,LOCATION_MZONE,0,1,1,nil,0xa6c)
	Duel.HintSelection(g)
	if #g==0 then return end
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CHANGE_BATTLE_DAMAGE)
	e1:SetValue(aux.ChangeBattleDamage(1,DOUBLE_DAMAGE))
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,2)
	g:GetFirst():RegisterEffect(e1)
end
