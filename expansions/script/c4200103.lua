--Godspark of Sanctuary - Havenia
--Created and Scripted by Swaggy
local m=4200103
local cm=_G["c"..m]
function cm.initial_effect(c)
c:SetSPSummonOnce(4200103)
--"The Mayakashi Clause"
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetTarget(cm.sslimit)
	c:RegisterEffect(e1)
	--Yeetus from handespacitus
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetTarget(cm.sptg)
	e2:SetOperation(cm.spop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
	end
		function cm.sslimit(e,c,sump,sumtype,sumpos,targetp,se)
	return c:IsLocation(LOCATION_EXTRA) and not c:IsSetCard(0x412)
end
function cm.filter(c,e,tp)
	return c:IsSetCard(0x412) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function cm.addfilter(c)
return c:IsSetCard(0x412) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
function cm.sparkfilter(c)
return c:IsCode(4200100)
end
function cm.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(cm.filter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
		if Duel.IsExistingMatchingCard(cm.sparkfilter,tp,LOCATION_GRAVE,0,1,nil) then
		local g=Duel.GetMatchingGroup(cm.addfilter,tp,0,LOCATION_GRAVE,nil)
		if #g>0 then
		Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
		end
	end
end
function cm.spop(e,tp,eg,ep,ev,re,r,rp)
	local ifclause=false
	local g=Duel.SelectMatchingCard(tp,cm.filter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		if Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)~=0 and Duel.IsExistingMatchingCard(cm.sparkfilter,tp,LOCATION_GRAVE,0,1,nil) then
			ifclause=true
		end
		if ifclause and Duel.IsExistingMatchingCard(cm.addfilter,tp,0,LOCATION_GRAVE,1,nil) then
			local sg=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(cm.addfilter),tp,0,LOCATION_GRAVE,1,1,nil)
			if #sg>0 then
				Duel.HintSelection(sg)
				Duel.SendtoHand(sg,nil,REASON_EFFECT)
			end
		end
	end
end