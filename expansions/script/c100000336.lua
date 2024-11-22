--[[
Manaseal Miscreation
Aberrazione Manasigillo
Card Author: Walrus
Scripted by: XGlitchy30
]]

local s,id=GetID()
function s.initial_effect(c)
	aux.AddCodeList(c,CARD_MANASEAL_RUNE_WEAVING)
	--This card can make a number of attacks during each Battle Phase, up to the number of Traps with different names in your GY.
	c:SetMaximumNumberOfAttacks(s.extraatk)
	--[[If this card is in your hand or GY, and you control a DARK "Number" Xyz Monster, or "Manaseal Rune Weaving": You can banish 1 Trap from your GY; Special Summon this card, and if you do, add 1
	"Rank-Up-Magic" Spell from your Deck or GY to your hand.]]
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(id,0)
	e1:SetCategory(CATEGORIES_SEARCH|CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND|LOCATION_GRAVE)
	e1:HOPT()
	e1:SetFunctions(
		aux.LocationGroupCond(s.cfilter,LOCATION_ONFIELD,0,1),
		aux.BanishCost(s.rmcfilter,LOCATION_GRAVE,0,1,1,true),
		s.sptg,
		s.spop
	)
	c:RegisterEffect(e1)
	--[[During the Main Phase, if you control "Manaseal Rune Weaving" (Quick Effect): You can either detach 2 materials from a DARK Xyz Monster you control or Tribute this card; take 1 "Manaseal" or
	"Remnant" Spell/Trap from your Deck, and either add it to your hand or Set it to your field.]]
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(id,1)
	e2:SetCategory(CATEGORIES_SEARCH)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:HOPT()
	e2:SetHintTiming(TIMING_MAIN_END)
	e2:SetFunctions(
		aux.AND(aux.LocationGroupCond(aux.FaceupFilter(Card.IsCode,CARD_MANASEAL_RUNE_WEAVING),LOCATION_ONFIELD,0,1),aux.MainPhaseCond()),
		s.thcost,
		s.thtg,
		s.thop
	)
	c:RegisterEffect(e2)
end
--E1
function s.extraatk(e)
	local tp=e:GetHandlerPlayer()
	local g=Duel.Group(Card.IsTrap,tp,LOCATION_GRAVE,0,nil)
	local ct=g:GetClassCount(Card.GetCode)
	return math.max(0,ct-1)
end

--E2
function s.cfilter(c)
	return c:IsFaceup() and (c:IsCode(CARD_MANASEAL_RUNE_WEAVING) or (c:IsLocation(LOCATION_MZONE) and c:IsAttribute(ATTRIBUTE_DARK) and c:IsSetCard(ARCHE_NUMBER) and c:IsType(TYPE_XYZ)))
end
function s.rmcfilter(c,_,tp)
	return c:IsTrap() and Duel.IsExists(false,s.thfilter,tp,LOCATION_DECK|LOCATION_GRAVE,0,1,c)
end
function s.thfilter(c)
	return c:IsSpell() and c:IsSetCard(ARCHE_RUM) and c:IsAbleToHand()
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		return Duel.GetMZoneCount(tp)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
			and (e:IsCostChecked() or Duel.IsExists(false,s.thfilter,tp,LOCATION_DECK|LOCATION_GRAVE,0,1,nil))
	end
	Duel.SetCardOperationInfo(c,CATEGORY_SPECIAL_SUMMON)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK|LOCATION_GRAVE)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToChain() and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0 then
		local g=Duel.Select(HINTMSG_ATOHAND,false,tp,aux.Necro(s.thfilter),tp,LOCATION_DECK|LOCATION_GRAVE,0,1,1,nil)
		if #g>0 then
			Duel.Search(g)
		end
	end
end

--E2
function s.filter(c)
	return c:IsST() and c:IsSetCard(ARCHE_MANASEAL,ARCHE_REMNANT) and (c:IsAbleToHand() or c:IsSSetable())
end
function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local g=Duel.Group(aux.FaceupFilter(Card.IsType,TYPE_XYZ),tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	local b1=c:IsReleasable()
	local b2=g:CheckRemoveOverlayCard(tp,2,REASON_COST)
	if chk==0 then return b1 or b2 end
	local opt=aux.Option(tp,nil,nil,{b1,STRING_RELEASE},{b2,STRING_DETACH})
	if opt==0 then
		Duel.Release(c,REASON_COST)
	elseif opt==1 then
		g:RemoveOverlayCard(tp,2,2,REASON_COST)
	end
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IsExists(false,s.filter,tp,LOCATION_DECK,0,1,nil)
	end
	Duel.SetPossibleOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.Select(HINTMSG_OPERATECARD,false,tp,s.filter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.ToHandOrSSet(g:GetFirst(),tp)
	end
end