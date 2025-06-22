--[[
Sceluspecter Recurrence
Card Author: Walrus
Scripted by: XGlitchy30
]]

local s,id=GetID()
function s.initial_effect(c)
	--Shuffle as many "Sceluspecter" cards from your GY and banishment into the Deck as possible, and if you do, and your LP is above 4000, your LP becomes 2000. You cannot Special Summon other monsters during the turn you activate this effect, except "Sceluspecter" and "Number" monsters.
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(id,0)
	e1:SetCategory(CATEGORY_TODECK)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:HOPT()
	e1:SetFunctions(
		nil,
		aux.SSRestrictionCost(aux.ArchetypeFilter({ARCHE_SCELUSPECTER,ARCHE_NUMBER}),true,nil,id,nil,1,true),
		s.target,
		s.activate
	)
	c:RegisterEffect(e1)
	--If this card is in your GY while you control no monsters: You can banish this card from your GY; Special Summon 3 "Sceluspecter" monsters from your hand, Deck, or GY, and if you do, their Levels become 7.
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(id,2)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_GRAVE)
	e2:SHOPT()
	e2:SetFunctions(s.spcon,aux.bfgcost,s.sptg,s.spop)
	c:RegisterEffect(e2)
end

--E1
function s.filter(c)
	return c:IsFaceupEx() and c:IsSetCard(ARCHE_SCELUSPECTER) and c:IsAbleToDeck()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(s.filter,tp,LOCATION_GB,0,nil)
	if chk==0 then return #g>0 end
	Duel.SetCardOperationInfo(g,CATEGORY_TODECK)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(aux.Necro(s.filter),tp,LOCATION_GB,0,nil)
	if #g>0 and Duel.ShuffleIntoDeck(g)>0 and Duel.GetLP(tp)>4000 then
		Duel.SetLP(tp,2000)
	end
end

--E2
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)==0
end
function s.spfilter(c,e,tp)
	return c:IsSetCard(ARCHE_SCELUSPECTER) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return not Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT)
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>2
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND|LOCATION_DECK|LOCATION_GRAVE,0,3,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,3,tp,LOCATION_HAND|LOCATION_DECK|LOCATION_GRAVE)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then return end
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<3 then return end
	local g=Duel.GetMatchingGroup(aux.Necro(s.spfilter),tp,LOCATION_HAND|LOCATION_DECK|LOCATION_GRAVE,0,nil,e,tp)
	if #g>=3 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local sg=g:Select(tp,3,3,nil)
		local c=e:GetHandler()
		for tc in aux.Next(sg) do
			if Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP) then
				tc:ChangeLevel(7,true,{c,true})
			end
		end
		Duel.SpecialSummonComplete()
	end
end