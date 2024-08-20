--[[
Spellbook of Synodos
Libro di Magia del Sinodo
Card Author: Kinny
Scripted by: XGlitchy30
]]

local s,id=GetID()
function s.initial_effect(c)
	--[[Banish other Spellcaster monsters and/or "Spellbook" cards from your hand, field, and/or GY, then Special Summon 1 "Prophecy" monster from your hand or Deck
	whose Level is less than or equal to the total Level of those cards. (Treat non-Monster Cards as Level 4.)]]
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(id,0)
	e1:SetCategory(CATEGORY_REMOVE|CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:HOPT(true)
	e1:SetFunctions(nil,nil,s.target,s.activate)
	c:RegisterEffect(e1)
end
--E1
function s.rmfilter(c)
	return c:IsFaceupEx() and (((c:IsLocation(LOCATION_MZONE) or (c:IsMonster() and not c:IsOnField())) and c:IsRace(RACE_SPELLCASTER)) or c:IsSetCard(ARCHE_SPELLBOOK))
		and (c:HasLevel() or not c:IsMonsterCard()) and c:IsAbleToRemove()
end
function s.total(c)
	if c:IsMonsterCard() then
		return c:GetLevel()
	else
		return 4
	end
end
function s.gcheck(min)
	return	function(g,e,tp,mg,c)
				local sum=g:GetSum(s.total)
				local ft=Duel.GetMZoneCount(tp,g)
				return ft>0 and sum>=min
			end
end
function s.spfilter(c,e,tp,sum)
	return c:IsSetCard(ARCHE_PROPHECY) and c:HasLevel() and (not sum or c:IsLevelBelow(sum)) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local c=e:GetHandler()
		local g=Duel.Group(s.rmfilter,tp,LOCATION_HAND|LOCATION_ONFIELD|LOCATION_GRAVE,0,c)
		local sg=Duel.Group(s.spfilter,tp,LOCATION_HAND|LOCATION_DECK,0,nil,e,tp,nil)
		local _,min=sg:GetMinGroup(Card.GetLevel)
		return #g>0 and #sg>0 and aux.SelectUnselectGroup(g,e,tp,1,#g,s.gcheck(min),0)
	end
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_HAND|LOCATION_ONFIELD|LOCATION_GRAVE)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND|LOCATION_DECK)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=Duel.Group(s.rmfilter,tp,LOCATION_HAND|LOCATION_ONFIELD|LOCATION_GRAVE,0,aux.ExceptThis(c))
	local sg=Duel.Group(s.spfilter,tp,LOCATION_HAND|LOCATION_DECK,0,nil,e,tp,nil)
	local _,min=sg:GetMinGroup(Card.GetLevel)
	if #g<=0 or #sg<=0 then return end
	local rg=aux.SelectUnselectGroup(g,e,tp,1,#g,s.gcheck(min),1,tp,HINTMSG_REMOVE,s.gcheck(min))
	if #rg>0 then
		local values={}
		for tc in aux.Next(rg) do
			values[tc]=s.total(tc)
		end
		if Duel.Remove(rg,POS_FACEUP,REASON_EFFECT)>0 then
			local og=Duel.GetOperatedGroup()
			local sum=0
			for tc in aux.Next(og) do
				if values[tc] then
					sum=sum+values[tc]
				end
			end
			if sum>0 and Duel.GetMZoneCount(tp)>0 then
				local sg1=Duel.Select(HINTMSG_SPSUMMON,false,tp,s.spfilter,tp,LOCATION_HAND|LOCATION_DECK,0,1,1,nil,e,tp,sum)
				if #sg1>0 then
					Duel.BreakEffect()
					Duel.SpecialSummon(sg1,0,tp,tp,false,false,POS_FACEUP)
				end
			end
		end
	end
end