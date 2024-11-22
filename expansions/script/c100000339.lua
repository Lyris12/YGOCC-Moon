--[[
Manaseal Imp
Imp Manasigillo
Card Author: Walrus
Scripted by: XGlitchy30
]]

local s,id=GetID()
function s.initial_effect(c)
	if not s.progressive_id then
		s.progressive_id=id
	else
		s.progressive_id=s.progressive_id+1
	end
	aux.AddCodeList(c,CARD_MANASEAL_RUNE_WEAVING)
	--[[When your opponent activates a Spell Card or effect (Quick Effect): You can discard this card and 1 other Trap or DARK monster, except "Manaseal Imp"; negate the activation, and if you do,
	banish it.]]
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(id,0)
	e1:SetCategory(CATEGORY_NEGATE|CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP|EFFECT_FLAG_DAMAGE_CAL)
	e1:SetCode(EVENT_CHAINING)
	e1:SetRange(LOCATION_HAND)
	e1:HOPT()
	e1:SetFunctions(s.discon,s.discost,s.distg,s.disop)
	c:RegisterEffect(e1)
	--[[If you Special Summon a "Manaseal" monster(s), or if you Special Summon a DARK monster(s) while you control "Manaseal Rune Weaving", while this card is in your GY (except during the Damage
	Step): You can banish 1 Spell/Trap from your GY; Special Summon this card, and if you do, its Level becomes equal to the Level/Rank of 1 of those Summoned monsters.]]
	aux.RegisterMergedDelayedEventGlitchy(c,s.progressive_id,EVENT_SPSUMMON_SUCCESS,s.evfilter,id,LOCATION_GRAVE,nil,LOCATION_GRAVE)
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(id,2)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_CUSTOM+s.progressive_id)
	e2:SetRange(LOCATION_GRAVE)
	e2:HOPT()
	e2:SetFunctions(
		nil,
		aux.BanishCost(Card.IsST,LOCATION_GRAVE,0,1,1,true),
		s.sptg,
		s.spop
	)
	c:RegisterEffect(e2)
end

--E1
function s.discon(e,tp,eg,ep,ev,re,r,rp)
	return not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED) and rp==1-tp
		and re:IsActiveType(TYPE_SPELL) and Duel.IsChainNegatable(ev)
end
function s.cfilter(c)
	return c:IsDiscardable() and (c:IsTrap() or c:IsAttribute(ATTRIBUTE_DARK)) and not c:IsCode(id)
end
function s.discost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsDiscardable() and Duel.IsExists(false,s.cfilter,tp,LOCATION_HAND,0,1,c) end
	local g=Duel.Select(HINTMSG_DISCARD,false,tp,s.cfilter,tp,LOCATION_HAND,0,1,1,c)
	g:AddCard(c)
	Duel.SendtoGrave(g,REASON_COST|REASON_DISCARD)
end
function s.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return aux.nbtg(e,tp,eg,ep,ev,re,r,rp,chk) end
	--[[During the End Phase of the turn the previous ① effect is activated, add 1 "Manaseal" card from your Deck to your hand, except "Manaseal Imp".]]
	local e2=Effect.CreateEffect(e:GetHandler())
	e2:SetDescription(id,1)
	e2:SetCategory(CATEGORIES_SEARCH)
	e2:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_CONTINUOUS)
	e2:SetProperty(EFFECT_FLAG_OATH)
	e2:SetCode(EVENT_PHASE|PHASE_END)
	e2:SetCountLimit(1,id+200)
	e2:SetCondition(aux.LocationGroupCond(s.thfilter,LOCATION_DECK,0,1))
	e2:SetOperation(s.thop)
	e2:SetReset(RESET_PHASE|PHASE_END)
	Duel.RegisterEffect(e2,tp)
	aux.nbtg(e,tp,eg,ep,ev,re,r,rp,chk)
end
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToChain(ev) then
		Duel.Remove(eg,POS_FACEUP,REASON_EFFECT)
	end
end
function s.thfilter(c)
	return c:IsSetCard(ARCHE_MANASEAL) and c:IsAbleToHand() and not c:IsCode(id)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_CARD,0,id)
	local g=Duel.Select(HINTMSG_ATOHAND,false,tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.Search(g)
	end
end

--E2
function s.evfilter(c,_,tp)
	return c:IsFaceup() and c:IsSummonPlayer(tp) and (c:HasLevel() or c:HasRank())
		and (c:IsSetCard(ARCHE_MANASEAL) or (c:IsAttribute(ATTRIBUTE_DARK) and Duel.IsExists(false,aux.FaceupFilter(Card.IsCode,CARD_MANASEAL_RUNE_WEAVING),tp,LOCATION_ONFIELD,0,1,nil)))
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetTargetCard(eg)
	Duel.SetCardOperationInfo(c,CATEGORY_SPECIAL_SUMMON)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToChain() and Duel.SpecialSummonStep(c,0,tp,tp,false,false,POS_FACEUP) then
		local g=Duel.GetTargetCards():Filter(aux.Faceup(aux.OR(Card.HasLevel,Card.HasRank)),nil)
		if #g>0 then
			local tc=g:GetFirst()
			if #g>1 then
				Duel.HintMessage(tp,aux.Stringid(id,3))
				tc=g:Select(tp,1,1,nil):GetFirst()
			end
			Duel.HintSelection(Group.FromCards(tc))
			c:ChangeLevel(tc:GetRatingAuto(),true,c)
		end
	end
	Duel.SpecialSummonComplete()
end