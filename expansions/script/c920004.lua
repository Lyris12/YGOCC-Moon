--[[
Curseflame Sorcerer Barisse
Stregone Fiammaledetta Barisse
Card Author: Walrus
Scripted by: XGlitchy30
]]

local s,id=GetID()
function s.initial_effect(c)
	--[[During your Main Phase, if this card is in your hand or GY: You can shuffle 2 of your banished "Curseflame" cards into the Deck; Special Summon this card, and if you do, distribute 3 Curseflame Counters among face-up cards on the field.]]
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(id,0)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON|CATEGORY_COUNTER)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND|LOCATION_GRAVE)
	e1:HOPT()
	e1:SetFunctions(
		nil,
		aux.ToDeckCost(aux.FaceupFilter(Card.IsSetCard,ARCHE_CURSEFLAME),LOCATION_REMOVED,0,2,2,nil,LOCATION_DECK),
		s.target,
		s.operation
	)
	c:RegisterEffect(e1)
	--Your opponent cannot Tribute monsters that have a Curseflame Counter, or use them as material for the Summon of monsters from the Extra Deck.
	Auxiliary.PlayerCannotTributeOrUseAsMaterial(c,LOCATION_MZONE,0,1,LOCATION_MZONE,LOCATION_MZONE,s.limtg)
end
--E1
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local g=Duel.Group(Card.IsFaceup,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	g:AddCard(c)
	if chk==0 then
		return Duel.GetMZoneCount(tp)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
			and g:CheckSubGroup(aux.DistributeCountersGroupCheck(COUNTER_CURSEFLAME,false,LOCATION_MZONE),1,#g,3)
	end
	Duel.SetCardOperationInfo(c,CATEGORY_SPECIAL_SUMMON)
	Duel.SetOperationInfo(0,CATEGORY_COUNTER,nil,3,tp,COUNTER_CURSEFLAME)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToChain() and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0 then
		local g=Duel.Group(Card.IsFaceup,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
		if #g>0 then
			Duel.DistributeCounters(tp,COUNTER_CURSEFLAME,3,g,id)
		end
	end
end

--E2
function s.limtg(e,c)
	return c:HasCounter(COUNTER_CURSEFLAME)
end