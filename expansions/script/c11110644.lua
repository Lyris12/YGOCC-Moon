--Bigbang Rush
--Frenesia Bigbang
--Scripted by: XGlitchy30

local s,id,o=GetID()
function s.initial_effect(c)
	--[[If you control a face-up Bigbang monster: Special Summon 1 monster from your hand or GY, and if you do, destroy 1 monster you control,
	then, if you destroyed a Bigbang monster with this effect, you can send 1 card from the field to the GY.]]
	local e1=Effect.CreateEffect(c)
	e1:Desc(0)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON|CATEGORY_DESTROY|CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:HOPT(true)
	e1:SetRelevantTimings()
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
--FE1
function s.spfilter(c,e,tp)
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
--E1
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExists(false,aux.FaceupFilter(Card.IsMonster,TYPE_BIGBANG),tp,LOCATION_MZONE,0,1,nil)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.GetMZoneCount(tp)>0 and Duel.IsExists(false,s.spfilter,tp,LOCATION_HAND|LOCATION_GRAVE,0,1,nil,e,tp)
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND|LOCATION_GRAVE)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,nil,1,tp,LOCATION_MZONE)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetMZoneCount(tp)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),tp,LOCATION_HAND|LOCATION_GRAVE,0,1,1,nil,e,tp)
	if #g==0 then return end
	local sc=g:GetFirst()
	if sc and Duel.SpecialSummon(sc,0,tp,tp,false,false,POS_FACEUP)>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
		local dg=Duel.SelectMatchingCard(tp,aux.TRUE,tp,LOCATION_MZONE,0,1,1,nil)
		if #dg>0 then
			Duel.HintSelection(dg)
			local c=e:GetHandler()
			local typecheck=dg:GetFirst():IsType(TYPE_BIGBANG)
			if Duel.Destroy(dg,REASON_EFFECT)>0 and typecheck and Duel.IsExists(false,Card.IsAbleToGrave,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,aux.ActivateException(e)) and c:AskPlayer(tp,1) then
				local tg=Duel.Select(HINTMSG_TOGRAVE,false,tp,Card.IsAbleToGrave,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,aux.ActivateException(e))
				if #tg>0 then
					Duel.HintSelection(tg)
					Duel.BreakEffect()
					Duel.SendtoGrave(tg,REASON_EFFECT)
				end
			end
		end
	end
end