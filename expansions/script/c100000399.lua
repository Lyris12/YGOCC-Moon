--[[
Unknown HERO Mercury
Card Author: Walrus
Scripted by: XGlitchy30
]]

local s,id=GetID()
function s.initial_effect(c)
	aux.RegisterCustomArchetype(id,CUSTOM_ARCHE_UNKNOWN_HERO)
	aux.AddCodeList(c,CARD_UNKNOWN_HERO_CALLING)
	-- If a "HERO" monster(s) you control is sent to the GY because of an opponent's card: You can Special Summon this card from your GY (if it was there when it was sent to the GY) or hand (even if not), and if you do, send 1 face-up card your opponent controls to the GY.
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(id,0)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON|CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY|EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetRange(LOCATION_HAND|LOCATION_GRAVE)
	e1:SetLabelObject(aux.AddThisCardInGraveAlreadyCheck(c))
	e1:HOPT()
	e1:SetFunctions(aux.AlreadyInRangeEventCondition(s.cfilter,LOCATION_HAND),nil,s.sptg,s.spop)
	c:RegisterEffect(e1)                                                          
	--If this card is Normal or Special Summoned: You can add 1 "Unknown HERO" Ritual Monster and 1 "Unknown HERO Calling Card" from your Deck or GY to your hand.
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(id,1)
	e2:SetCategory(CATEGORIES_SEARCH)
	e2:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:HOPT()
	e2:SetFunctions(nil,nil,s.thtg,s.thop)
	c:RegisterEffect(e2)
	e2:SpecialSummonEventClone(c)
end	
--E1
function s.cfilter(c,_,tp)
	return c:IsPreviousControler(tp) and c:IsPreviousLocation(LOCATION_MZONE) and c:IsPreviousPosition(POS_FACEUP) and c:IsPreviousSetCard(ARCHE_HERO) and c:IsMonster() and c:IsSetCard(ARCHE_HERO)
		and c:IsReasonPlayer(1-tp)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local g=Duel.Group(aux.FaceupFilter(Card.IsAbleToGrave),tp,0,LOCATION_ONFIELD,nil)
	if chk==0 then
		return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and #g>0
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,g,1,0,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToChain() and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0 then
		local g=Duel.Select(HINTMSG_TOGRAVE,false,tp,aux.FaceupFilter(Card.IsAbleToGrave),tp,0,LOCATION_ONFIELD,1,1,nil)
		if Duel.Highlight(g) then
			Duel.SendtoGrave(g,REASON_EFFECT)
		end
	end
end

--E2
function s.thfilter2(c,tp)
	return c:IsCustomArchetype(CUSTOM_ARCHE_UNKNOWN_HERO) and c:IsMonster(TYPE_RITUAL) and c:IsAbleToHand()
		and Duel.IsExistingMatchingCard(s.thfilter3,tp,LOCATION_DECK|LOCATION_GRAVE,0,1,c)
end
function s.thfilter3(c)
	return c:IsCode(CARD_UNKNOWN_HERO_CALLING) and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter2,tp,LOCATION_DECK|LOCATION_GRAVE,0,1,nil,tp) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK|LOCATION_GRAVE)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g1=Duel.SelectMatchingCard(tp,aux.Necro(s.thfilter2),tp,LOCATION_DECK|LOCATION_GRAVE,0,1,1,nil,tp)
	if #g1>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local g2=Duel.SelectMatchingCard(tp,aux.Necro(s.thfilter3),tp,LOCATION_DECK|LOCATION_GRAVE,0,1,1,g1:GetFirst())
		g1:Merge(g2)
		Duel.Search(g1)
	end
end