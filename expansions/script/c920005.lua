--[[
Curseflame Seal
Sigillo Fiammaledetta
Card Author: Walrus
Scripted by: XGlitchy30
]]

local s,id,o=GetID()
function s.initial_effect(c)
	--Negate the effects of all face-up cards currently on the field with a Curseflame Counter, except "Curseflame" cards, then you can draw 1 card for every 3 cards that had their effects negated by this effect.
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(id,0)
	e1:SetCategory(CATEGORY_DISABLE|CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:HOPT()
	e1:SetRelevantTimings()
	e1:SetFunctions(
		nil,
		nil,
		s.target,
		s.activate
	)
	c:RegisterEffect(e1)
	--If this card is in your GY: You can remove 3 Curseflame Counters from anywhere on the field; add this card to your hand, then Special Summon 1 "Curseflame" monster from your hand or GY, and if you do, place Curseflame Counters on it equal to its original Level/Rank/Link Rating.
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(id,1)
	e2:SetCategory(CATEGORY_TOHAND|CATEGORY_SPECIAL_SUMMON|CATEGORY_COUNTER)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SHOPT()
	e2:SetFunctions(
		nil,
		aux.RemoveCounterCost(COUNTER_CURSEFLAME,3,1,1),
		s.thtg,
		s.thop
	)
	c:RegisterEffect(e2)
end

--E1
function s.filter(c)
	return c:HasCounter(COUNTER_CURSEFLAME) and not c:IsSetCard(ARCHE_CURSEFLAME) and aux.NegateAnyFilter(c)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.Group(s.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	if chk==0 then return #g>0 end
	Duel.SetTargetPlayer(tp)
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,g,#g,PLAYER_ALL,LOCATION_ONFIELD)
	Duel.SetPossibleOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.Group(s.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil):Filter(Card.IsCanBeDisabledByEffect,nil,e)
	if #g>0 then
		local ct=math.floor(Duel.Negate(g,e,0,false,false,TYPE_NEGATE_ALL)/3)
		local p=Duel.GetTargetPlayer()
		if ct>=1 and Duel.IsPlayerCanDraw(p,ct) and Duel.SelectYesNo(p,STRING_ASK_DRAW) then
			Duel.BreakEffect()
			Duel.Draw(p,ct,REASON_EFFECT)
		end
	end
end

--E2
function s.spfilter(c,e,tp)
	local lv,type=c:GetOriginalRatingAuto()
	return lv>0 and (type==0 or type&TYPE_XYZ|TYPE_LINK>0) and c:IsSetCard(ARCHE_CURSEFLAME) and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and c:IsCanAddCounter(COUNTER_CURSEFLAME,lv,false,LOCATION_MZONE)
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		return c:IsAbleToHand() and Duel.GetMZoneCount(tp)>0 and Duel.IsExists(false,s.spfilter,tp,LOCATION_HAND|LOCATION_GRAVE,0,1,c,e,tp)
	end
	Duel.SetCardOperationInfo(c,CATEGORY_TOHAND)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND|LOCATION_GRAVE)
	Duel.SetOperationInfo(0,CATEGORY_COUNTER,nil,1,tp,COUNTER_CURSEFLAME)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToChain() and Duel.SearchAndCheck(c,tp) and Duel.GetMZoneCount(tp)>0 then
		Duel.ShuffleHand(tp)
		local tc=Duel.Select(HINTMSG_SPSUMMON,false,tp,aux.Necro(s.spfilter),tp,LOCATION_HAND|LOCATION_GRAVE,0,1,1,nil,e,tp):GetFirst()
		if tc then
			Duel.BreakEffect()
			if Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)>0 then
				local lv,type=tc:GetOriginalRatingAuto()
				if lv>0 and (type==0 or type&TYPE_XYZ|TYPE_LINK>0) and tc:IsCanAddCounter(COUNTER_CURSEFLAME,lv) then
					tc:AddCounter(COUNTER_CURSEFLAME,lv)
				end
			end
		end
	end
end