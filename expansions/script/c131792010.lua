--created by LeonDuvall, coded by Lyris
--Metallic Concentrated Magitate
local s,id,o=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	aux.AddLinkProcedure(c,s.mfilter,1,1)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_DESTROYED)
	e1:SetRange(LOCATION_REMOVED)
	e1:SetCountLimit(1,id)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCondition(s.con)
	e1:SetCost(s.cost)
	e1:SetTarget(s.tg)
	e1:SetOperation(s.op)
	c:RegisterEffect(e1)
end
function s.mfilter(c)
	return c:IsLevelBelow(4) and not c:IsLinkAttribute(ATTRIBUTE_FIRE) and c:IsSetCard(0xd16)
end
function s.cfilter(c)
	return c:IsPreviousPosition(POS_FACEUP) and c:GetPreviousLevelOnField()==5 and c:IsPreviousSetCard(0xd16)
end
function s.con(e,tp,eg)
	return eg:IsExists(s.cfilter,1,nil)
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToExtraAsCost() end
	Duel.SendtoDeck(c,nil,SEQ_DECKTOP,REASON_COST)
end
function s.filter(c,tp)
	local e=c:GetActivateEffect()
	return c:IsSetCard(0xd16) and c:IsType(TYPE_SPELL+TYPE_TRAP) and (c:IsType(TYPE_FIELD)
		or Duel.GetLocationCount(tp,LOCATION_SZONE)>0) and c:CheckActivateEffect(true,false)
		and e:GetCode()==EVENT_FREE_CHAIN and e:IsActivatable(tp)
end
function s.tg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_GRAVE+LOCATION_HAND,0,1,nil,tp) end
end
function s.op(e,tp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
	local sc=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.filter),tp,LOCATION_GRAVE+LOCATION_HAND,0,1,1,nil,tp):GetFirst()
	if not sc then return end
	if sc:IsType(TYPE_FIELD) then
		local fc=Duel.GetFieldCard(tp,LOCATION_FZONE,0)
		if fc then
			Duel.SendtoGrave(fc,REASON_RULE)
			Duel.BreakEffect()
		end
		Duel.MoveToField(sc,tp,tp,LOCATION_FZONE,POS_FACEUP,true)
		Duel.RaiseEvent(sc,4179255,te,0,tp,tp,Duel.GetCurrentChain())
	else Duel.MoveToField(sc,tp,tp,LOCATION_SZONE,POS_FACEUP,true) end
	local te=sc:GetActivateEffect()
	te:UseCountLimit(tp,1,true)
	local tep=sc:GetControler()
	Duel.ClearTargetCard()
	local cost=te:GetCost()
	if cost then cost(te,tep,eg,ep,ev,re,r,rp,1) end
	if not sc:IsType(TYPE_CONTINUOUS+TYPE_FIELD) then
		local c=e:GetHandler()
		c:SetEntityCode(sc:GetOriginalCode(),true)
		local trg=te:GetTarget()
		if trg then trg(te,tep,eg,ep,ev,re,r,rp,1)
		local op=te:GetOperation()
		if op then
			sc:CreateEffectRelation(te)
			local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
			for tg in aux.Next(g) do tg:CreateEffectRelation(te) end
			op(te,tep,eg,ep,ev,re,r,rp)
			sc:ReleaseEffectRelation(te)
			for tg in aux.Next(g) do tg:ReleaseEffectRelation(te) end
		end
		c:SetEntityCode(id)
	end
	if not (sc:GetEquipTarget() or sc:IsType(TYPE_CONTINUOUS+TYPE_FIELD)) then
		sc:CancelToGrave(false)
	end
	if sc:IsType(TYPE_SPELL) then Duel.RaiseEvent(sc,73734821,te,0,tp,tp,Duel.GetCurrentChain()) end
end
