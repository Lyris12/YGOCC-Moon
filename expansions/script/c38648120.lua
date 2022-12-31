--Portale della Città di Elyria
--Script by XGlitchy30
function c38648120.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_DESTROYED)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,38648120+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c38648120.target)
	e1:SetOperation(c38648120.activate)
	c:RegisterEffect(e1)
end
--filters
function c38648120.filter(c,e,tp)
	return c:IsPreviousPosition(POS_FACEUP) and c:GetPreviousControler()==tp and c:IsPreviousLocation(LOCATION_MZONE) and c:IsType(TYPE_LINK)
end
function c38648120.spfilter(c,e,tp)
	return c:IsType(TYPE_MONSTER) and c:IsType(TYPE_NORMAL) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		and ((c:IsFaceup() and c:IsLocation(LOCATION_EXTRA) and Duel.GetLocationCountFromEx(tp)>0) or c:IsLocation(LOCATION_GRAVE))
end
--Activate
function c38648120.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return eg:IsExists(c38648120.filter,1,nil,e,tp) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(c38648120.spfilter,tp,LOCATION_GRAVE+LOCATION_EXTRA,0,1,nil,e,tp) 
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE+LOCATION_EXTRA)
end
function c38648120.activate(e,tp,eg,ep,ev,re,r,rp)
	local extra=0
	local g=nil
	local g2=nil
	if Duel.GetLocationCountFromEx(tp)>1 then
		extra=2
	elseif Duel.GetLocationCountFromEx(tp)==1 then
		extra=1
	else
		extra=0
	end
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if ft<=0 then return end
	if ft>=2 then ft=2 end
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then ft=1 end
	if extra==2 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c38648120.spfilter),tp,LOCATION_GRAVE+LOCATION_EXTRA,0,1,ft,nil,e,tp)
	elseif extra==1 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c38648120.spfilter),tp,LOCATION_GRAVE+LOCATION_EXTRA,0,1,1,nil,e,tp)
		if ft>1 then
			if g:GetFirst():IsLocation(LOCATION_EXTRA) then
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
				g2=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c38648120.spfilter),tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
			else
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
				g2=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c38648120.spfilter),tp,LOCATION_GRAVE+LOCATION_EXTRA,0,1,1,nil,e,tp)
			end
		end
		if g2~=nil then
			g:Merge(g2)
		end
	else
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c38648112.spfilter),tp,LOCATION_GRAVE,0,1,ft,nil,e,tp)
	end
	if g:GetCount()>0 then
		local t1=g:GetFirst()
		local t2=g:GetNext()
		Duel.SpecialSummonStep(t1,0,tp,tp,false,false,POS_FACEUP)
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_UNCOPYABLE)
		e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
		e1:SetValue(1)
		e1:SetReset(RESET_EVENT+0x1fe0000+RESET_PHASE+PHASE_END)
		t1:RegisterEffect(e1)
		if t2 then
			Duel.SpecialSummonStep(t2,0,tp,tp,false,false,POS_FACEUP)
			local e2=e1:Clone()
			t2:RegisterEffect(e2)
		end
		Duel.SpecialSummonComplete()
	end
end