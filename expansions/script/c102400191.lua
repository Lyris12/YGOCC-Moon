--created & coded by Lyris, art from Yu-Gi-Oh! GX episode 83
--ストライデント・ブラスト
local s,id,o=GetID()
function s.initial_effect(c)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.target)
	c:RegisterEffect(e1)
end
function s.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x1093)
end
function s.ffilter(c)
	return c:IsFaceup() and c:IsType(TYPE_FUSION) and c:GetOriginalRace()&RACE_MACHINE>0
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local b1=Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil)
	local b2=Duel.IsExistingMatchingCard(s.ffilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil)
		and Duel.IsExistingMatchingCard(Card.IsAbleToRemove,tp,0,LOCATION_ONFIELD,1,nil)
	if chk==0 then return b1 or b2 end
	local off=1
	local ops={}
	local opval={}
	if b1 then
		ops[off]=1124
		opval[off-1]=1
		off=off+1
	end
	if b2 then
		ops[off]=1192
		opval[off-1]=2
		off=off+1
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EFFECT)
	local op=Duel.SelectOption(tp,table.unpack(ops))
	if opval[op]==1 then
		e:SetCategory(CATEGORY_DESTROY)
		e:SetOperation(s.destroy)
		local g=Duel.GetFieldGroup(tp,LOCATION_ONFIELD,LOCATION_ONFIELD)
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	else
		e:SetCategory(CATEGORY_REMOVE)
		e:SetOperation(s.remove)
		local g=Duel.GetFieldGroup(tp,0,LOCATION_ONFIELD)
		Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
	end
end
function s.destroy(e,tp,eg,ep,ev,re,r,rp)
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetCode(EFFECT_CANNOT_ACTIVATE)
	e3:SetTargetRange(0,1)
	e3:SetCondition(s.condition)
	e3:SetValue(1)
	Duel.RegisterEffect(e3,tp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.GetFieldGroup(0,LOCATION_ONFIELD,LOCATION_ONFIELD):Select(tp,1,1,nil)
	Duel.HintSelection(g)
	Duel.Destroy(g,REASON_EFFECT)
end
function s.condition(e)
	local ph=Duel.GetCurrentPhase()
	return ph>=PHASE_BATTLE_START and ph<=PHASE_BATTLE
end
function s.remove(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,Card.IsAbleToRemove,tp,0,LOCATION_ONFIELD,1,1,nil)
	Duel.HintSelection(g)
	Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
end
