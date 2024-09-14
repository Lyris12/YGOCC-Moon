--[[
Automatyrant Subspace Core
Automatiranno Nucleo Subspaziale
Card Author: Walrus
Scripted by: XGlitchy30
]]

local s,id=GetID()
function s.initial_effect(c)
	--link summon
	c:EnableReviveLimit()
	aux.AddLinkProcedure(c,s.matfilter,1,1)
	--Special Summon (from your Extra Deck) by Tributing 1 Equip Card you control.
	local proc=Effect.CreateEffect(c)
	proc:SetDescription(id,2)
	proc:SetType(EFFECT_TYPE_FIELD)
	proc:SetProperty(EFFECT_FLAG_CANNOT_DISABLE|EFFECT_FLAG_UNCOPYABLE)
	proc:SetCode(EFFECT_SPSUMMON_PROC)
	proc:SetRange(LOCATION_EXTRA)
	proc:SetCondition(s.hspcon)
	proc:SetTarget(s.hsptg)
	proc:SetOperation(s.hspop)
	c:RegisterEffect(proc)
	--Summoning condition
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE|EFFECT_FLAG_UNCOPYABLE)
	e0:SetCode(EFFECT_SPSUMMON_CONDITION)
	e0:SetValue(aux.linklimit)
	c:RegisterEffect(e0)
	--[[If this card is Link Summoned, or when another "Automatyrant" card(s) is sent to the GY while you control this card (except during the Damage Step):
	You can add 1 "Automatyrant" card from your Deck or GY to your hand, then, if there is a Special Summoned monster with 2500 or more ATK on the field,
	you can send the top 4 cards of your Deck to the GY.]]
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(id,0)
	e1:SetCategory(CATEGORIES_SEARCH|CATEGORY_DECKDES)
	e1:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:HOPT()
	e1:SetFunctions(
		aux.LinkSummonedCond,
		nil,
		s.thtg,
		s.thop
	)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(id,0)
	e2:SetCategory(CATEGORIES_SEARCH|CATEGORY_DECKDES)
	e2:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetRange(LOCATION_MZONE)
	e2:SHOPT()
	e2:SetLabelObject(aux.AddThisCardInMZoneAlreadyCheck(c))
	e2:SetFunctions(
		s.thcon,
		nil,
		s.thtg,
		s.thop
	)
	c:RegisterEffect(e2)
	--[[(During the Main Phase or Battle Phase, except during the Damage Step (Quick Effect): You can target 1 "Automatyrant" monster in your GY;
	Special Summon that target, and if you do, equip this card to that monster as an Equip Spell that gives it 1000 ATK.]]
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(id,1)
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON|CATEGORY_EQUIP)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_MZONE)
	e3:SetRelevantTimings()
	e3:HOPT()
	e3:SetFunctions(
		aux.MainOrBattlePhaseCond(),
		nil,
		s.sptg,
		s.spop
	)
	c:RegisterEffect(e3)
end
s.has_text_type=TYPE_UNION

function s.matfilter(c)
	return c:IsLinkType(TYPE_UNION) or c:IsLinkRace(RACE_MACHINE)
end

--PROC
function s.hspfilter(c,tp,sc)
	return c:IsEquipCard() and Duel.GetLocationCountFromEx(tp,tp,c,sc)>0 and c:IsCanBeLinkMaterial(sc) and c:IsReleasable(REASON_SPSUMMON)
end
function s.hspcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	local g=Duel.Group(s.hspfilter,tp,LOCATION_SZONE,0,nil,tp,c)
	return #g>0
end
function s.hsptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	local g=Duel.Group(s.hspfilter,tp,LOCATION_SZONE,0,nil,tp,c)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
	local tc=g:SelectUnselect(nil,tp,false,true,1,1)
	if tc then
		e:SetLabelObject(tc)
		return true
	else return false end
end
function s.hspop(e,tp,eg,ep,ev,re,r,rp,c)
	local tc=e:GetLabelObject()
	c:SetMaterial(Group.FromCards(tc))
	Duel.Release(tc,REASON_SPSUMMON)
end

--E1
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return not eg:IsContains(c) and eg:IsExists(aux.AlreadyInRangeFilter(e,Card.IsSetCard),1,c,ARCHE_AUTOMATYRANT)
end
function s.thfilter(c)
	return c:IsSetCard(ARCHE_AUTOMATYRANT) and c:IsAbleToHand()
end
function s.cfilter(c)
	return c:IsFaceup() and c:IsAttackAbove(2500) and c:IsSpecialSummoned()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IsExists(false,s.thfilter,tp,LOCATION_DECK|LOCATION_GRAVE,0,1,nil)
	end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK|LOCATION_GRAVE)
	Duel.SetPossibleOperationInfo(0,CATEGORY_DECKDES,nil,0,tp,4)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.Select(HINTMSG_ATOHAND,false,tp,aux.Necro(s.thfilter),tp,LOCATION_DECK|LOCATION_GRAVE,0,1,1,nil)
	if #g>0 and Duel.SearchAndCheck(g) and Duel.IsExists(false,s.cfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil)
		and Duel.IsPlayerCanDiscardDeck(tp,4) and Duel.SelectYesNo(tp,STRING_ASK_DECKDES) then
		Duel.BreakEffect()
		Duel.DiscardDeck(tp,4,REASON_EFFECT)
	end
end

--E2
function s.spfilter(c,e,tp)
	return c:IsSetCard(ARCHE_AUTOMATYRANT) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.spfilter(chkc,e,tp) end
	local c=e:GetHandler()
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		and Duel.IsExistingTarget(s.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp)
		and not c:IsForbidden() and c:CheckUniqueOnField(tp,LOCATION_SZONE)
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectTarget(tp,s.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	Duel.SetCardOperationInfo(g,CATEGORY_SPECIAL_SUMMON)
	Duel.SetCardOperationInfo(c,CATEGORY_EQUIP)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToChain() and Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)>0 then
		local c=e:GetHandler()
		if c:IsRelateToChain() and c:IsFaceup() and Duel.EquipToOtherCardAndRegisterLimit(e,tp,c,tc,true) then
			local e2=Effect.CreateEffect(c)
			e2:SetType(EFFECT_TYPE_EQUIP)
			e2:SetCode(EFFECT_UPDATE_ATTACK)
			e2:SetValue(1000)
			e2:SetReset(RESET_EVENT|RESETS_STANDARD)
			c:RegisterEffect(e2)
		end
	end
end