--created by Jake, coded by Lyris
--Steinitz's Promotion
local s,id,o=GetID()
function s.initial_effect(c)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:HOPT(true)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_EQUIP)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.cfilter(c,tp,g)
	return c:IsFaceupEx() and c:IsSetCard(0x63d0) and c:IsAbleToRemoveAsCost()
		and (Duel.IsExistingMatchingCard(Card.IsSummonType,tp,0,LOCATION_MZONE,0,2,nil,SUMMON_TYPE_SPECIAL)
			or g:IsExists(aux.NOT(Card.IsCode),1,nil,c:GetCode()))
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(s.filter,tp,LOCATION_DECK+LOCATION_HAND,0,nil,e,tp)
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_GRAVE+LOCATION_MZONE,0,1,nil,tp,g) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local tc=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_GRAVE+LOCATION_MZONE,0,1,1,nil):GetFirst()
	Duel.Remove(tc,POS_FACEUP,REASON_COST)
	e:SetLabel(tc:GetCode())
end
function s.sfilter(c,e,tp,...)
	return c:IsSetCard(0x63d0) and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and (#({...})<1
		or not c:IsCode(...))
end
function s.filter(c,tp)
	return c:IsSetCard(0x63d0) and c:IsType(TYPE_MONSTER) and c:CheckUniqueOnField(tp) and not c:IsForbidden()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local b=e:IsCostChecked() and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK+LOCATION_HAND,0,1,nil,e,tp)
	if chk==0 then return b or Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		and Duel.IsExistingMatchingCard(Card.IsSummonType,tp,0,LOCATION_MZONE,0,2,nil,SUMMON_TYPE_SPECIAL)
		and (b or Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)>0)
		and Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil) end
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler(
	local g1=Duel.GetMatchingGroup(s.sfilter,tp,LOCATION_DECK+LOCATION_HAND,0,nil,e,tp,e:GetLabel())
	local g2=Duel.GetMatchingGroup(aux.NecroValleyFilter(s.filter),tp,LOCATION_DECK+LOCATION_GRAVE,0,nil,tp)
	local b1=Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and #g1>0
	local b2=Duel.IsExistingMatchingCard(Card.IsSummonType,tp,0,LOCATION_MZONE,0,2,nil,SUMMON_TYPE_SPECIAL)
		and Duel.GetLocationCount(tp,LOCATION_SZONE)>0 and (b or Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)>0)
		and #g2>0
	if not b1 or b2 then return end
	local op=aux.SelectFromOptions(tp,{b1,1152},{b2,1068},{b1 and b2,aux.Stringid(id,0)})
	local tc
	if op&1>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local sc=g1:Select(tp,1,1,nil):GetFirst()
		if sc and Duel.SpecialSummonStep(sc,0,tp,tp,false,false,POS_FACEUP) then
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_SPIRIT_MAYNOT_RETURN)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			sc:RegisterEffect(e1)
			if Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)<2 then tc=sc end
		end
		Duel.SpecialSummonComplete()
	end
	if op&2>0 then
		if op>2 then Duel.BreakEffect() end
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
		local qc=g2:Select(tp,1,1,nil):GetFirst()
		if not tc then
			local g=Duel.GetFieldGroup(tp,LOCATION_MZONE)
			if #g>1 then
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
				tc=g:Select(tp,1,1,nil):GetFirst()
			else tc=g:GetFirst() end
		end
		if not (qc and Duel.Equip(tp,qc,tc,true)) then return end
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_EQUIP_LIMIT)
		e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e2:SetLabelObject(tc)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		e2:SetValue(s.eqlimit)
		qc:RegisterEffect(e2)
	end
end
function s.eqlimit(e,c)
	return e:GetLabelObject()==c
end
