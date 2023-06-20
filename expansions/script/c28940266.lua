--Reivalis, Fearsome Tempo
local ref,id=GetID()
Duel.LoadScript("Marionightte.lua")
function ref.initial_effect(c)
	--Bigbang
	c:EnableReviveLimit()
	aux.AddOrigBigbangType(c)
	aux.AddBigbangProc(c,aux.FilterBoolFunction(Card.IsAttribute,ATTRIBUTE_DARK),1,1,aux.TRUE,1)

	Marionightte.Induct(c,200)
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,id)
	e1:SetTarget(ref.thtg)
	e1:SetOperation(ref.thop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(function(e,tp,eg) return eg:IsExists(aux.FilterEqualFunction(Card.GetOwner,1-tp),1,nil) end)
	c:RegisterEffect(e2)
end

function ref.tgfilter(c,tp)
	return c:IsType(TYPE_MONSTER)
		and Duel.IsExistingMatchingCard(ref.thfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil,c:GetRace())
end
function ref.thfilter(c,typ)
	return Marionightte.Is(c) and Marionightte.IsRaceInText(c,typ) and c:IsAbleToHand(c)
end
function ref.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return ref.tgfilter(chkc,tp) and chkc:IsLocation(LOCATION_MZONE+LOCATION_GRAVE) end
	if chk==0 then return
		Duel.IsExistingTarget(ref.tgfilter,tp,LOCATION_MZONE+LOCATION_GRAVE,LOCATION_MZONE+LOCATION_GRAVE,1,nil,tp)
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	local g=Duel.SelectTarget(tp,ref.tgfilter,tp,LOCATION_MZONE+LOCATION_GRAVE,LOCATION_MZONE+LOCATION_GRAVE,1,1,nil,tp)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end
function ref.thop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local g=Duel.SelectMatchingCard(tp,ref.thfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil,tc:GetRace())
		if #g>0 and Duel.SendtoHand(g,nil,REASON_EFFECT)~=0 then
			Duel.ConfirmCards(1-tp,g)
			if (not tc:IsRace(RACE_MACHINE)) and Duel.IsExistingMatchingCard(Card.IsCanBeSpecialSummoned,tp,LOCATION_HAND,0,1,nil,e,0,tp,false,false) and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
				local sg=Duel.SelectMatchingCard(tp,Card.IsCanBeSpecialSummoned,tp,LOCATION_HAND,0,1,1,nil,e,0,tp,false,false)
				if #sg>0 then
					Duel.BreakEffect()
					Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
				end
			end
		end
	end
end
