--Terrestrial Elemerge, Gaia
Duel.LoadScript("Elemerge.lua")
local ref,id=GetID()
function ref.initial_effect(c)
	aux.AddFusionProcFun2(c,ref.rcmatfilter,ref.attmatfilter,true)
	--OnSummon
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetTarget(ref.thtg)
	e1:SetOperation(ref.thop)
	c:RegisterEffect(e1)
	
end
function ref.rcmatfilter(c) return c:IsRace(RACE_PLANT) end
function ref.attmatfilter(c) return c:IsFusionAttribute(ATTRIBUTE_EARTH) end

function ref.thfilter(c,p) return Elemerge.Is(c) and c:GetOwner()==p and c:IsAbleToHand() end
function ref.ssfilter(c,e,tp) return c:IsLevelBelow(4) and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
function ref.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(ref.thfilter,tp,LOCATION_ONFIELD+LOCATION_GRAVE+LOCATION_REMOVED,LOCATION_ONFIELD,1,nil,tp) end
	local g=Duel.GetMatchingGroup(ref.thfilter,tp,LOCATION_ONFIELD+LOCATION_GRAVE+LOCATION_REMOVED,LOCATION_ONFIELD,nil,tp)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,tp,LOCATION_GRAVE)
	local val=math.min(Duel.GetLocationCount(tp,LOCATION_MZONE,0),Elemerge.GetAttributeCount(ATTRIBUTE_EARTH,2),Duel.GetMatchingGroupCount(ref.ssfilter,tp,LOCATION_GRAVE,LOCATION_GRAVE,nil,e,tp))
	if val>0 then
		e:SetCategory(e:GetCategory()+CATEGORY_SPECIAL_SUMMON)
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
	end
end

function ref.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,ref.thfilter,tp,LOCATION_ONFIELD+LOCATION_GRAVE+LOCATION_REMOVED,LOCATION_ONFIELD,1,1,nil,tp)
	if #g>0 then
		Duel.HintSelection(g)
		if Duel.SendtoHand(g,nil,REASON_EFFECT)==0 then return end
		local e0=Effect.CreateEffect(e:GetHandler())
		e0:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e0:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
		e0:SetTargetRange(1,0)
		e0:SetTarget(function(e,c) return c:IsCode(id) end)
		e0:SetReset(RESET_PHASE+PHASE_END)
		Duel.RegisterEffect(e0,tp)
		local val=math.min(Duel.GetLocationCount(tp,LOCATION_MZONE,0),Elemerge.GetAttributeCount(ATTRIBUTE_EARTH,2),Duel.GetMatchingGroupCount(ref.ssfilter,tp,LOCATION_GRAVE,LOCATION_GRAVE,nil,e,tp))
		Debug.Message(Duel.GetLocationCount(tp,LOCATION_MZONE,0)..","..(Elemerge.GetAttributeCount(ATTRIBUTE_EARTH,2))..","..Duel.GetMatchingGroupCount(ref.ssfilter,tp,LOCATION_GRAVE,LOCATION_GRAVE,nil,e,tp))
		Debug.Message(val)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local g2=Duel.SelectMatchingCard(tp,ref.ssfilter,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,val,nil,e,tp)
		if #g2>0 then
			local tc=g2:GetFirst()
			for tc in aux.Next(g2) do
				Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP)
				local e1=Effect.CreateEffect(e:GetHandler())
				e1:SetType(EFFECT_TYPE_SINGLE)
				e1:SetCode(EFFECT_DISABLE)
				e1:SetReset(RESET_EVENT+RESETS_STANDARD)
				tc:RegisterEffect(e1,true)
				local e2=e1:Clone()
				e2:SetCode(EFFECT_DISABLE_EFFECT)
				tc:RegisterEffect(e2,true)
			end
			Duel.SpecialSummonComplete()
			
		end
	end
end
