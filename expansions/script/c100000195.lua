--[[
Litharion, the Regal Ferocity of Earth
Litharion, la Regale Ferocia della Terra
Card Author: Xarc
Scripted by: XGlitchy30
]]

local s,id=GetID()
function s.initial_effect(c)
	aux.AddOrigDriveType(c)
	aux.AddDriveProc(c,12)
	--[[▼ [-1]: Tribute any number of EARTH Beast monsters from your hand and/or face-up field, and if you do, decrease this card's Energy by the number of Tributed monsters.]]
	local d1=c:DriveEffect({-1,true},0,{CATEGORY_RELEASE,CATEGORY_UPDATE_ENERGY},EFFECT_TYPE_IGNITION,nil,nil,
		nil,
		nil,
		s.trtg,
		s.trop
	)
	--[[▼ [-2]: (Quick Effect): Target 1 face-up monster your opponent controls; it loses 600 ATK/DEF until the end of the next turn.]]
	local d2=c:DriveEffect(-2,1,CATEGORIES_ATKDEF,EFFECT_TYPE_QUICK_O,EFFECT_FLAG_CARD_TARGET,EVENT_FREE_CHAIN,
		aux.dscon,
		nil,
		s.atktg,
		s.atkop
	)
	--[[[OD]: Add 1 Level 7 or lower EARTH Beast monster from your Deck to your hand.]]
	local d3=c:OverDriveEffect(2,CATEGORIES_SEARCH,EFFECT_TYPE_IGNITION,nil,nil,
		nil,
		nil,
		s.thtg,
		s.thop
	)
	
	--[[EARTH Beast monsters you control cannot be destroyed by card effects.]]
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(aux.TargetBoolFunction(Card.IsAttributeRace,ATTRIBUTE_EARTH,RACE_BEAST))
	e1:SetValue(1)
	c:RegisterEffect(e1)
	--[[You can target 1 EARTH Beast monster in either GY; Special Summon it, also you cannot Special Summon monsters for the rest of this turn, except EARTH Beast monsters.]]
	local e2=Effect.CreateEffect(c)
	e2:Desc(3)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:HOPT()
	e2:SetFunctions(nil,nil,s.sptg,s.spop)
	c:RegisterEffect(e2)
	--[[If this card is in your GY: You can banish 2 or more EARTH Beast monsters from your GY whose total Levels equal 12 or more; add this card to your hand.]]
	local e3=Effect.CreateEffect(c)
	e3:Desc(5)
	e3:SetCategory(CATEGORY_TOHAND)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_GRAVE)
	e3:HOPT()
	e3:SetFunctions(nil,s.thcost,s.thtg2,s.thop2)
	c:RegisterEffect(e3)
end
--D1
function s.trfilter(c)
	return c:IsFaceupEx() and c:IsAttributeRace(ATTRIBUTE_EARTH,RACE_BEAST) and c:IsReleasableByEffect()
end
function s.pubfilter(c)
	return not c:IsPublic() or (c:IsAttributeRace(ATTRIBUTE_EARTH,RACE_BEAST))
end
function s.trtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local g=Duel.Group(s.trfilter,tp,LOCATION_HAND|LOCATION_MZONE,0,nil)
	if chk==0 then
		return #g>0 and c:IsCanUpdateEnergy(-1,tp,REASON_EFFECT,e)
	end
	if not Duel.IsExistingMatchingCard(s.pubfilter,tp,LOCATION_HAND,0,1,nil) then
		Duel.SetOperationInfo(0,CATEGORY_RELEASE,g,1,tp,LOCATION_HAND|LOCATION_MZONE)
	else
		Duel.SetOperationInfo(0,CATEGORY_RELEASE,nil,1,tp,LOCATION_HAND|LOCATION_MZONE)
	end
	Duel.SetCustomOperationInfo(0,CATEGORY_UPDATE_ENERGY,c,1,tp,LOCATION_HAND,-1)
	if c:IsEngaged() then
		aux.RememberEngagedID(c,e)
	else
		e:SetLabel(0)
	end
end
function s.gcheck(c)
	return	function(g,e,tp)
				return c:IsCanUpdateEnergy(tp,-#g,REASON_EFFECT,e), false
			end
end
function s.trop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.Group(s.trfilter,tp,LOCATION_HAND|LOCATION_MZONE,0,nil)
	if #g<=0 then return end
	local rg
	local c=e:GetHandler()
	if c:IsRelateToChain() and c:IsEngaged() and c:GetEngagedID()==e:GetLabel() then
		rg=aux.SelectUnselectGroup(g,e,tp,1,#g,s.gcheck(c),1,tp,HINTMSG_RELEASE,nil,nil,false)
	else
		Duel.HintMessage(tp,HINTMSG_RELEASE)
		rg=g:Select(tp,1,#g,nil)
	end
	if rg and #rg>0 then
		local rgf,rgh=rg:Filter(aux.NOT(Card.IsLocation),nil,LOCATION_HAND),rg:Filter(Card.IsLocation,nil,LOCATION_HAND)
		if #rgf>0 then
			Duel.HintSelection(rgf)
		end
		if #rgh>0 then
			Duel.ConfirmCards(1-tp,rgh)
		end
		local ct=Duel.Release(rg,REASON_EFFECT)
		if ct>0 then
			if c:IsRelateToChain() and c:IsEngaged() and c:GetEngagedID()==e:GetLabel() and c:IsCanUpdateEnergy(tp,-ct,REASON_EFFECT,e) then
				c:UpdateEnergy(-ct,tp,REASON_EFFECT,true,c,e)
			end
		end
	end
end

--D2
function s.atktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and chkc:IsCanChangeStats() end
	if chk==0 then return Duel.IsExistingTarget(Card.IsCanChangeStats,tp,0,LOCATION_MZONE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	local g=Duel.SelectTarget(tp,Card.IsCanChangeStats,tp,0,LOCATION_MZONE,1,1,nil)
	Duel.SetCustomOperationInfo(0,CATEGORIES_ATKDEF,g,#g,1-tp,LOCATION_MZONE,-600)
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToChain() and tc:IsCanChangeStats() then
		tc:UpdateATKDEF(-600,-600,{RESET_PHASE|PHASE_END,2},{e:GetHandler(),true})
	end
end

--D3
function s.thfilter(c)
	return c:IsLevelBelow(7) and c:IsAttributeRace(ATTRIBUTE_EARTH,RACE_BEAST) and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.Search(g,tp)
	end
end

--E2
function s.filter(c,e,tp)
	return c:IsAttributeRace(ATTRIBUTE_EARTH,RACE_BEAST) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and s.filter(chkc,e,tp) end
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingTarget(s.filter,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,nil,e,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectTarget(tp,s.filter,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,1,nil,e,tp)
	Duel.SetCardOperationInfo(g,CATEGORY_SPECIAL_SUMMON)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToChain() then
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET|EFFECT_FLAG_CLIENT_HINT)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetDescription(aux.Stringid(id,4))
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	e1:SetReset(RESET_PHASE|PHASE_END)
	Duel.RegisterEffect(e1,tp)
end
function s.splimit(e,c,tp,sumtp,sumpos)
	return not c:IsAttributeRace(ATTRIBUTE_EARTH,RACE_BEAST)
end

--E3
function s.costfilter(c)
	return c:IsAttributeRace(ATTRIBUTE_EARTH,RACE_BEAST) and c:HasLevel() and c:IsAbleToRemoveAsCost()
end
function s.lvcheck(g)
	return g:GetSum(Card.GetLevel)>=12
end
function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(s.costfilter,tp,LOCATION_GRAVE,0,e:GetHandler())
	if chk==0 then return aux.SelectUnselectGroup(g,e,tp,2,#g,s.lvcheck,0) end
	local rg=aux.SelectUnselectGroup(g,e,tp,2,#g,s.lvcheck,1,tp,HINTMSG_REMOVE,s.lvcheck,nil,false)
	Duel.Remove(rg,POS_FACEUP,REASON_COST)
end
function s.thtg2(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToHand() end
	Duel.SetCardOperationInfo(c,CATEGORY_TOHAND)
end
function s.thop2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToChain() then
		Duel.Search(c,tp)
	end
end