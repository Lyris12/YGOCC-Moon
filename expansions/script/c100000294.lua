--[[
Dynastygian Battlefield
Campo di Battaglia Dinastigiano
Card Author: Walrus
Scripted by: XGlitchy30
]]

local s,id=GetID()
function s.initial_effect(c)
	--[[When this card is activated: Add a number of Level 4 "Dynastygian" monster from your Deck or GY to your hand with different original names,
	up to the number of Special Summoned monsters your opponent controls (if any). You cannot add cards from your Deck to your hand for the rest of this turn after this effect resolves,
	except by drawing them.]]
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(id,0)
	e1:SetCategory(CATEGORIES_SEARCH|CATEGORY_GRAVE_ACTION)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:HOPT(true)
	e1:SetFunctions(
		nil,
		nil,
		s.target,
		s.operation
	)
	c:RegisterEffect(e1)
	--[[Each turn, you can Normal Summon 1 "Dynastygian" monster, in addition to your Normal Summon/Set. (You can only gain this effect of "Dynastygian Battlefield" once per turn.)]]
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(id,2)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_EXTRA_SUMMON_COUNT)
	e2:SetRange(LOCATION_FZONE)
	e2:SetTargetRange(LOCATION_HAND|LOCATION_MZONE,0)
	e2:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,ARCHE_DYNASTYGIAN))
	c:RegisterEffect(e2)
	--[[Once per turn, during the End Phase, your opponent takes 400 damage for each material attached to face-up Xyz Monsters on the field. If your opponent activated a "Dynastygian" Normal Trap you own previously this turn, or if they control a "Number" Xyz Monster that has material, this effect does not apply.]]
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(id,3)
	e3:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_PHASE|PHASE_END)
	e3:SetRange(LOCATION_FZONE)
	e3:OPT()
	e3:SetCondition(s.damcon)
	e3:SetOperation(s.damop)
	c:RegisterEffect(e3)
	Duel.AddCustomActivityCounter(id,ACTIVITY_CHAIN,s.chainfilter)
end
function s.chainfilter(re,rp,cid)
	return not (re:GetActiveType()==TYPE_TRAP and re:IsHasType(EFFECT_TYPE_ACTIVATE) and re:GetHandler():IsOwner(1-rp) and re:GetHandler():IsSetCard(ARCHE_DYNASTYGIAN))
end

--E1
function s.thfilter(c)
	return c:IsMonster() and c:IsSetCard(ARCHE_DYNASTYGIAN) and c:IsLevel(4) and c:IsAbleToHand()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local spchk=Duel.IsExists(false,Card.IsSpecialSummoned,tp,0,LOCATION_MZONE,1,nil)
	if chk==0 then return not spchk or Duel.IsExists(false,s.thfilter,tp,LOCATION_DECK|LOCATION_GRAVE,0,1,nil) end
	Duel.SetConditionalOperationInfo(spchk,0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK|LOCATION_GRAVE)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local ct=Duel.Group(Card.IsSpecialSummoned,tp,0,LOCATION_MZONE,nil):GetCount()
	local g=Duel.Group(aux.Necro(s.thfilter),tp,LOCATION_DECK|LOCATION_GRAVE,0,nil)
	if ct>0 and #g>0 then
		local sg=aux.SelectUnselectGroup(g,e,tp,1,ct,aux.ogdncheckbrk,1,tp,HINTMSG_ATOHAND)
		if #sg>0 and Duel.SearchAndCheck(sg) then
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetDescription(id,1)
			e1:SetType(EFFECT_TYPE_FIELD)
			e1:SetCode(EFFECT_CANNOT_TO_HAND)
			e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET|EFFECT_FLAG_CLIENT_HINT)
			e1:SetTargetRange(1,0)
			e1:SetTarget(s.thlimit)
			e1:SetReset(RESET_PHASE|PHASE_END)
			Duel.RegisterEffect(e1,tp)
		end
	end
end
function s.thlimit(e,c)
	return c:IsLocation(LOCATION_DECK) and c:IsControler(e:GetOwnerPlayer())
end

--E2
function s.excfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_XYZ) and c:IsSetCard(ARCHE_NUMBER) and c:GetOverlayCount()>0
end
function s.damcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetCustomActivityCount(id,1-tp,ACTIVITY_CHAIN)==0 and not Duel.IsExists(false,s.excfilter,tp,0,LOCATION_MZONE,1,nil)
end
function s.damop(e,tp,eg,ep,ev,re,r,rp)
	local ct=Duel.GetXyzMaterialGroupCount(tp,1,1,Card.IsFaceup)
	if ct>0 then
		Duel.Hint(HINT_CARD,tp,id)
		Duel.Damage(1-tp,ct*400,REASON_EFFECT)
	end
end