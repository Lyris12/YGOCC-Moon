--created by Slick, coded by Lyris
--Belgrade Security Force
local s,id,o=GetID()
function s.initial_effect(c)
	c:RegisterSetCardString"Kronologistic"
	local d1=c:DriveEffect(2,nil,CATEGORY_COIN,nil,nil,nil,aux.NOT(s.qcon),nil,s.deutg,s.deuop)
	local q1=d1:Clone()
	q1:SetType(EFFECT_TYPE_QUICK_O)
	q1:SetCondition(s.qcon)
	c:RegisterEffect(q1)
	local d2=c:DriveEffect(-8,nil,CATEGORY_DISABLE,nil,EFFECT_FLAG_CARD_TARGET,nil,aux.AND(s.discon,aux.NOT(s.qcon)),nil,s.distg,s.disop)
	local q2=d2:Clone()
	q2:SetType(EFFECT_TYPE_QUICK_O)
	q2:SetCondition(aux.AND(s.discon,s.qcon))
	c:RegisterEffect(q2)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_NONTUNER)
	e1:SetValue(s.tnval)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetTarget(s.destg)
	e2:SetOperation(s.desop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetCondition(s.con)
	c:RegisterEffect(e3)
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetCode(EFFECT_INDESTRUCTABLE_COUNT)
	e4:SetRange(LOCATION_MZONE)
	e4:SetTargetRange(LOCATION_MZONE,0)
	e4:SetCondition(s.con)
	e4:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,"Kronologistic"))
	e4:SetValue(s.indct)
	c:RegisterEffect(e4)
end
s.toss_coin=true
function s.tnval(e,c)
	return e:GetHandler():IsControler(c:GetControler())
end
function s.qcon(_,tp)
	return Duel.IsPlayerAffectedByEffect(tp,212111811)
end
function s.deutg(e,tp,_,_,_,_,_,_,chk)
	if chk==0 then return e:GetHandler():IsCanUpdateEnergy(2,tp,REASON_EFFECT) end
	Duel.SetOperationInfo(0,CATEGORY_COIN,nil,0,tp,1)
end
function s.deuop(e,tp)
	if Duel.TossCoin(tp,1)>0 then e:GetHandler():UpdateEnergy(2,tp,REASON_EFFECT) end
end
function s.discon(e,tp)
	return Duel.IsEnvironment(212111811,tp)
end
function s.distg(e,tp,_,_,_,_,_,_,chk,chkc)
	if chkc then then return chk:IsOnField() and chkc:IsControler(1-tp) and aux.NegateAnyFilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(aux.NegateAnyFilter,tp,0,LOCATION_ONFIELD,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	Duel.SelectTarget(tp,aux.NegateAnyFilter,tp,0,LOCATION_ONFIELD,1,1,nil)
end
function s.disop(e)
	local tc=Duel.GetFirstTarget()
	if not tc:IsRelateToEffect() or tc:IsFacedown() then return end
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_DISABLE)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	tc:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_DISABLE_EFFECT)
	e2:SetValue(RESET_TURN_SET)
	tc:RegisterEffect(e2)
end
function s.destg(e,tp,_,_,_,_,_,_,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) and chkc:IsType(TYPE_SPELL+TYPE_TRAP) end
	if chk==0 then return Duel.IsExistingTarget(Card.IsType,tp,0,LOCATION_ONFIELD,1,nil,TYPE_SPELL+TYPE_TRAP) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,Duel.SelectTarget(tp,Card.IsType,tp,0,LOCATION_ONFIELD,1,1,nil,TYPE_SPELL+TYPE_TRAP),1,0,0)
end
function s.desop()
	Duel.Destroy(Duel.GetTargetsRelateToChain(),REASON_EFFECT)
end
function s.con(e)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_DRIVE)
end
function s.indct(e,re,r,rp)
	if rp==1-tp and r&REASON_EFFECT>0 then
		return 1
	else return 0 end
end
