--Purple Metal Dragon
--scripted by Rawstone
local s,id=GetID()
function s.initial_effect(c)
		--sp from hand
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_SPSUMMON_PROC)
		e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
		e1:SetRange(LOCATION_HAND)
		e1:SetCountLimit(1,id)
		e1:SetCondition(s.sprcon)
		c:RegisterEffect(e1)
		-- banish from GY
		local e2=Effect.CreateEffect(c)
		e2:SetCategory(CATEGORY_REMOVE+CATEGORY_SPECIAL_SUMMON+CATEGORY_COIN)
		e2:SetDescription(aux.Stringid(id,0))
		e2:SetType(EFFECT_TYPE_IGNITION)
		e2:SetCode(EVENT_FREE_CHAIN)
		e2:SetCountLimit(1,id+500)
		e2:SetRange(LOCATION_MZONE)
		e2:SetTarget(s.trg)
		e2:SetOperation(s.op)
		c:RegisterEffect(e2)
end
	function s.sprfilter(c)
	return c:IsFaceup() and c:IsAttribute(ATTRIBUTE_DARK) and c:IsRace(RACE_MACHINE)
end
	c40005.toss_coin=true
	function s.sprcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.sprfilter,tp,LOCATION_MZONE,0,1,nil)
end
	function s.bfilter(c,e,tp)
	return c:IsType(TYPE_MONSTER) and c.toss_coin and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and Duel.GetMZoneCount(tp)>0
	and c:IsLocation(LOCATION_REMOVED) and c:IsFaceup()
end
	function s.trg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetFieldGroupCount(Card.IsAbleToRemove,tp,LOCATION_GRAVE,0,1-tp)>0 end
	if chk==0 then return ct>0 end
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,1-tp,LOCATION_GRAVE) 
	Duel.SetOperationInfo(0,CATEGORY_COIN,nil,1,tp,3)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,0,tp,LOCATION_REMOVED)
end
	function s.op(e,tp,eg,ep,ev,re,r,rp)
	local g2=Duel.GetMatchingGroup(s.bfilter,tp,LOCATION_REMOVED,0,nil,e,tp)
	local g=Duel.GetMatchingGroup(Card.IsAbleToRemove,tp,LOCATION_GRAVE,LOCATION_GRAVE,1-tp)
	if g:GetCount()==0 then return end
	local c1,c2,c3=Duel.TossCoin(tp,3)
	local ct=c1+c2+c3
		if ct==0 then return end
		if ct>g:GetCount() then ct=g:GetCount() end
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
		local g=Duel.SelectMatchingCard(tp,Card.IsAbleToRemove,tp,0,LOCATION_GRAVE,1-tp,ct,nil)
		if g:GetCount()>0 and g:IsExists(Card.IsAbleToRemove,1,1-tp) then
			Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
			if c1+c2+c3==3 then
			if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
				if g2:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(40005,0))  then
				Duel.BreakEffect()
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
				local sg2=g2:Select(tp,1,1,nil)
				Duel.SpecialSummon(sg2,0,tp,tp,false,false,POS_FACEUP)
			end
		end
	end
end




