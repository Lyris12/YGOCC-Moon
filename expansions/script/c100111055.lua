--created by Jake, coded by Lyris
--No Survivors
local s,id,o = GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	aux.AddFusionProcFunRep(c,aux.FilterBoolFunction(Card.IsAttribute,ATTRIBUTE_DARK),2,true)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetValue(aux.fuslimit)
	c:RegisterEffect(e1)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:HOPT()
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetCondition(s.dfcon)
	e1:SetCost(s.cost)
	e1:SetTarget(s.dftg)
	e1:SetOperation(s.dfop)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_DESTROYED)
	e2:SetRange(LOCATION_GRAVE)
	e2:HOPT()
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e2:SetCategory(CATEGORY_DESTROY+CATEGORY_DAMAGE)
	e2:SetLabelObject(aux.AddThisCardInGraveAlreadyCheck(c))
	e2:SetCondition(s.d1con)
	e2:SetCost(s.cost)
	e2:SetTarget(s.d1tg)
	e2:SetOperation(s.d1op)
	c:RegisterEffect(e2)
end
function s.cost(e,tp,_,_,_,_,_,_,chk)
	if chk==0 then return Duel.GetActivityCount(tp,ACTIVITY_BATTLE_PHASE)<1 end
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_BP)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetTargetRange(1,0)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
end
function s.dfcon(e,tp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_FUSION) and Duel.GetTurnPlayer()==tp
end
function s.dftg(e,tp,_,_,_,_,_,_,chk)
	if chk==0 then return true end
	local g=Duel.GetFieldGroup(tp,LOCATION_ONFIELD,LOCATION_ONFIELD)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,#g,0,0)
	Duel.SetChainLimit()
end
function s.dfop(_,tp)
	Duel.Destroy(Duel.GetFieldGroup(tp,LOCATION_ONFIELD,LOCATION_ONFIELD),REASON_EFFECT)
end
function s.d1con(e,_,eg)
	return eg:FilterCount(Card.IsReason,nil,REASON_EFFECT)==2
end
function s.d1tg(e,tp,_,_,_,_,_,_,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp)
		and chkc:IsFaceup() end
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,0,LOCATION_MZONE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	Duel.SelectTarget(tp,Card.IsFaceup,tp,0,LOCATION_MZONE,1,1,nil)
end
function s.d1op(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if not tc:IsRelateToChain() then return end
	local p,rst=Duel.GetTurnPlayer()
	if p==tp then rst=RESET_SELF_TURN else rst=RESET_OPPO_TURN end
	tc:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_DRAW+rst,0,1,tc:GetPosition())
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_PHASE+PHASE_END)
	e1:SetRange(LOCATION_MZONE)
	e1:SetLabel(p)
	e1:SetLabelObject(tc)
	e1:SetCondition(s.descon)
	e1:SetOperation(s.desop)
	e1:SetReset(RESET_PHASE+PHASE_END+rst)
	Duel.RegisterEffect(e1,tp)
end
function s.descon(e,tp)
	local tc=e:GetLabelObject()
	return Duel.GetTurnPlayer()==1-e:GetLabel() and tc and tc:GetFlagEffect(id)>0
end
function s.desop(e,tp)
	Duel.Hint(HINT_CARD,0,id)
	local tc=e:GetLabelObject()
	local pos=tc:GetFlagEffectLabel(id)
	if not tc or Duel.Destroy(tc,REASON_EFFECT)<1 or pos&POS_FACEUP<1 then return end
	local atk=math.max(tc:GetTextAttack(),0)
	for p=0,1 do Duel.Damage(p,atk,REASON_EFFECT,true) end
	Duel.RDComplete()
end
