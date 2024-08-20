--[[
Reaper, the Magistus of Prophecy
Mietitore, il Magistus della Profezia
Card Author: D1G1TAL
Scripted by: XGlitchy30
]]

local s,id=GetID()
function s.initial_effect(c)
	--[[If you control a "Magistus" monster, or you have 2 or more "Spellbook" Spells in your GY: You can Special Summon this card from your hand.]]
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(id,0)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:HOPT()
	e1:SetFunctions(
		s.spcon,
		nil,
		xgl.SpecialSummonSelfTarget(),
		xgl.SpecialSummonSelfOperation()
	)
	c:RegisterEffect(e1)
	--[[If this card is Normal or Special Summoned: You can send 1 "Spellbook" Spell from your Deck to the GY, then you can add 1 "Spellbook" card with a different name from your GY to your hand.]]
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(id,1)
	e2:SetCategory(CATEGORY_TOGRAVE|CATEGORY_TOHAND|CATEGORY_GRAVE_ACTION)
	e2:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:HOPT()
	e2:SetFunctions(
		nil,
		nil,
		s.tdtg,
		s.tdop
	)
	c:RegisterEffect(e2)
	e2:SpecialSummonEventClone(c)
	--[[If this card is sent to the GY, except from the hand or Deck: You can target 1 "Magistus" Equip Card or monster you control, except a Level 4 monster;
	Special Summon this card, and if you do, equip that target to this card.]]
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(id,2)
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON|CATEGORY_EQUIP)
	e3:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY|EFFECT_FLAG_CARD_TARGET)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:HOPT()
	e3:SetFunctions(
		s.speqcon,
		nil,
		s.speqtg,
		s.speqop
	)
	c:RegisterEffect(e3)
end

--E1
function s.filter1(c)
	return c:IsFaceup() and c:IsSetCard(ARCHE_MAGISTUS)
end
function s.filter2(c)
	return c:IsSpell() and c:IsSetCard(ARCHE_SPELLBOOK)
end
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExists(false,s.filter1,tp,LOCATION_MZONE,0,1,nil) or Duel.IsExists(false,s.filter2,tp,LOCATION_GRAVE,0,2,nil)
end

--E2
function s.tdfilter(c)
	return s.filter2(c) and c:IsAbleToGrave()
end
function s.thfilter(c,codes)
	return c:IsSetCard(ARCHE_SPELLBOOK) and c:IsAbleToHand() and not c:IsCode(table.unpack(codes))
end
function s.tdtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IsExists(false,s.tdfilter,tp,LOCATION_DECK,0,1,nil)
	end
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
	Duel.SetPossibleOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE)
end
function s.tdop(e,tp,eg,ep,ev,re,r,rp)
	local tg=Duel.Select(HINTMSG_TOGRAVE,false,tp,s.tdfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #tg>0 and Duel.SendtoGraveAndCheck(tg,tp,REASON_EFFECT) then
		local codes={tg:GetFirst():GetCode()}
		local thg=Duel.Group(aux.Necro(s.thfilter),tp,LOCATION_GRAVE,0,nil,codes)
		if #thg>0 and Duel.SelectYesNo(tp,STRING_ASK_SEARCH) then
			Duel.HintMessage(tp,HINTMSG_ATOHAND)
			local thg2=thg:Select(tp,1,1,nil)
			Duel.Search(thg2)
		end
	end
end

--E3
function s.speqcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:GetPreviousLocation()&(LOCATION_HAND|LOCATION_DECK)==0
end
function s.eqfilter(c,h,e,tp)
	if not c:IsFaceup() or not c:IsSetCard(ARCHE_MAGISTUS) or not h:IsCanBeEquippedWith(c,e,tp,REASON_EFFECT) then return false end
	if c:IsSpell(TYPE_EQUIP) then
		return not c:IsLocation(LOCATION_FZONE) and c:IsAppropriateEquipSpell(h,tp)
	else
		return c:IsLocation(LOCATION_MZONE) and not c:IsLevel(4)
	end
end
function s.speqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsOnField() and chkc:IsControler(tp) and s.eqfilter(chkc,c,e,tp) end
	if chk==0 then
		return Duel.GetLocationCount(tp,LOCATION_SZONE)>0 and Duel.GetMZoneCount(tp)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and Duel.IsExists(true,s.eqfilter,tp,LOCATION_ONFIELD,0,1,nil,c,e,tp)
	end
	local g=Duel.Select(HINTMSG_EQUIP,true,tp,s.eqfilter,tp,LOCATION_ONFIELD,0,1,1,nil,c,e,tp)
	Duel.SetCardOperationInfo(c,CATEGORY_SPECIAL_SUMMON)
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,c,1,tp,LOCATION_MZONE)
end
function s.speqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToChain() and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0 then
		local tc=Duel.GetFirstTarget()
		if tc:IsRelateToChain() and tc:IsFaceup() and tc:IsControler(tp) and tc:IsSetCard(ARCHE_MAGISTUS) and (tc:IsLocation(LOCATION_MZONE) or tc:IsSpell(TYPE_EQUIP)) then
			if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then
				Duel.SendtoGrave(tc,REASON_RULE,PLAYER_NONE)
			end
			Duel.EquipToOtherCardAndRegisterLimit(e,tp,tc,c)
		end
	end
end