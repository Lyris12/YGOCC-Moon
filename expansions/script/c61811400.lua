--[[
Dread Bastille - Cantata
Bastiglia dell'Angoscia - Cantata
Card Author: Swag
Scripted by: XGlitchy30
]]

local s,id=GetID()
function s.initial_effect(c)
	--You can discard this card; add 1 "Dread Bastille" card from your Deck to your hand, except "Dread Bastille - Cantata".
	local e1=Effect.CreateEffect(c)
	e1:Desc(0)
	e1:SetCategory(CATEGORIES_SEARCH)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:HOPT()
	e1:SetCost(aux.DiscardSelfCost)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	--[[You cannot Special Summon monsters during the turn you activate the following effect, except Rock monsters.
	If a "Dread Bastille" card(s) is sent from your hand or field to the GY (except during the Damage Step): You can Special Summon this card from your GY (if it was there when the monster was sent) or hand (even if not), but banish it if it leaves the field.]]
	local GYChk=aux.AddThisCardInGraveAlreadyCheck(c)
	local e2=Effect.CreateEffect(c)
	e2:Desc(2)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetRange(LOCATION_HAND|LOCATION_GRAVE)
	e2:HOPT()
	e2:SetLabelObject(GYChk)
	e2:SetCondition(s.spcon)
	e2:SetCost(s.spcost)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)	
	Duel.AddCustomActivityCounter(id,ACTIVITY_SPSUMMON,function(_c) return _c:IsRace(RACE_ROCK) end)
	--[[If this card is Special Summoned: You can activate 1 of the following effects:
	● Activate 1 "Dread Bastille's Overture" from your Deck.
	● Place 4 Soulflame Counters on a "Dread Bastille's Overture" you control.]]
	local e3=Effect.CreateEffect(c)
	e3:Desc(3)
	e3:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:HOPT()
	e3:SetTarget(s.target)
	e3:SetOperation(s.operation)
	c:RegisterEffect(e3)
end
--E1
function s.thfilter(c)
	return c:IsSetCard(ARCHE_DREAD_BASTILLE) and c:IsAbleToHand() and not c:IsCode(id,true)
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end

--E2
function s.cfilter(c,tp,se)
	if not c:IsSetCard(ARCHE_DREAD_BASTILLE) or not c:IsPreviousSetCard(ARCHE_DREAD_BASTILLE) or c:GetPreviousControler()~=tp or not (se==nil or c:GetReasonEffect()~=se) then return false end
	local loc=c:GetPreviousLocation()
	if loc==LOCATION_HAND then
		return true
	elseif loc==LOCATION_MZONE then
		return c:IsPreviousPosition(POS_FACEUP)
	end
	return false
end
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local se=e:GetLabelObject():GetLabelObject()
	return (not eg:IsContains(c) or c:IsLocation(LOCATION_HAND)) and eg:IsExists(s.cfilter,1,nil,tp,se)
end
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetCustomActivityCount(id,tp,ACTIVITY_SPSUMMON)==0 end
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetDescription(aux.Stringid(id,2))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET|EFFECT_FLAG_OATH|EFFECT_FLAG_CLIENT_HINT)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTargetRange(1,0)
	e1:SetTarget(function(_,c) return not c:IsRace(RACE_ROCK) end)
	e1:SetReset(RESET_PHASE|PHASE_END)
	Duel.RegisterEffect(e1,tp)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetCardOperationInfo(c,CATEGORY_SPECIAL_SUMMON)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToChain() then
		Duel.SpecialSummonRedirect(e,c,0,tp,tp,false,false,POS_FACEUP)
	end
end

--E3
function s.actfilter(c,tp)
	return c:IsCode(CARD_DREAD_BASTILLE_OVERTURE) and c:IsDirectlyActivatable(tp)
end
function s.ctfilter(c,tp)
	return c:IsFaceup() and c:IsCode(CARD_DREAD_BASTILLE_OVERTURE) and c:IsCanAddCounter(COUNTER_SOULFLAME,4)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local b1=Duel.IsExistingMatchingCard(s.actfilter,tp,LOCATION_DECK,0,1,nil,tp)
	local b2=Duel.IsExistingMatchingCard(s.ctfilter,tp,LOCATION_ONFIELD,0,1,nil)
	if chk==0 then
		return b1 or b2
	end
	local opt=aux.Option(tp,id,4,b1,b2)
	Duel.SetTargetParam(opt)
	if opt==0 then
		e:SetCategory(0)
	elseif opt==1 then
		e:SetCategory(CATEGORY_COUNTER)
		local g=Duel.GetMatchingGroup(s.ctfilter,tp,LOCATION_ONFIELD,0,nil)
		Duel.SetOperationInfo(0,CATEGORY_COUNTER,g,1,tp,LOCATION_ONFIELD)
		Duel.SetCustomOperationInfo(0,CATEGORY_COUNTER,g,1,tp,LOCATION_ONFIELD,COUNTER_SOULFLAME,4)
	end
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local opt=Duel.GetTargetParam()
	if not opt then return end
	if opt==0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_OPERATECARD)
		local g=Duel.SelectMatchingCard(tp,s.actfilter,tp,LOCATION_DECK,0,1,1,nil,tp)
		local tc=g:GetFirst()
		if tc then
			Duel.ActivateDirectly(tc,tp)
		end
	elseif opt==1 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_COUNTER)
		local g=Duel.SelectMatchingCard(tp,s.ctfilter,tp,LOCATION_ONFIELD,0,1,1,nil,tp)
		local tc=g:GetFirst()
		if tc then
			Duel.HintSelection(g)
			tc:AddCounter(COUNTER_SOULFLAME,4)
		end
	end
end