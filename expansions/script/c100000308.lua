--[[
Invernal of the Enchanted Blade
Invernale della Lama Incantata
Card Author: Walrus
Scripted by: XGlitchy30
]]

local s,id=GetID()
function s.initial_effect(c)
	--[[If you control no monsters, or if you control an "Invernal" monster, except "Invernal of the Blazing Caestus": You can send the top card of your Deck to the GY;
	Special Summon this card from your hand or GY.]]
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(id,0)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND|LOCATION_GRAVE)
	e1:HOPT()
	e1:SetFunctions(
		s.spcon,
		s.spcost,
		xgl.SpecialSummonSelfTarget(),
		xgl.SpecialSummonSelfOperation()
	)
	c:RegisterEffect(e1)
	--[[If this card is Normal or Special Summoned: You can add 1 "Invernal" card from your Deck or GY to your hand, except "Invernal of the Enchanted Blade".]]
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(id,1)
	e2:SetCategory(CATEGORIES_SEARCH)
	e2:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetFunctions(
		nil,
		nil,
		xgl.SearchTarget(s.spfilter,LOCATION_DECK|LOCATION_GRAVE,1,nil),
		xgl.SearchOperation(s.spfilter,LOCATION_DECK|LOCATION_GRAVE,1,1,nil)
	)
	c:RegisterEffect(e2)
	e2:SpecialSummonEventClone(c)
	--[[A DARK "Number" Xyz Monster that has this card as material gains this effect.
	● If this card attacks a Special Summoned monster, that monster's ATK becomes equal to half of its original ATK.]]
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(id,2)
	e3:SetType(EFFECT_TYPE_XMATERIAL|EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_BATTLE_START)
	e3:SetCondition(s.xmatcon)
	e3:SetOperation(s.xmatop)
	c:RegisterEffect(e3)
end
--E1
function s.cfilter(c)
	return c:IsFaceup() and s.spfilter(c)
end
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)==0 or Duel.IsExists(false,s.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDiscardDeckAsCost(tp,1) end
	Duel.DiscardDeck(tp,1,REASON_COST)
end

--E2
function s.spfilter(c)
	return c:IsSetCard(ARCHE_INVERNAL) and not c:IsCode(id)
end

--E3
function s.xmatcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsType(TYPE_XYZ) and c:IsSetCard(ARCHE_NUMBER) and c:IsAttribute(ATTRIBUTE_DARK)
end
function s.xmatop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if Duel.GetAttacker()==c then
		local bc=c:GetBattleTarget()
		if bc and bc:IsSpecialSummoned() then
			Duel.Hint(HINT_CARD,tp,c:GetOriginalCode())
			local e4=Effect.CreateEffect(c)
			e4:SetType(EFFECT_TYPE_SINGLE)
			e4:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e4:SetCode(EFFECT_SET_ATTACK_FINAL)
			e4:SetValue(s.atkval)
			e4:SetReset(RESET_EVENT|RESETS_STANDARD)
			bc:RegisterEffect(e4)
		end
	end
end

--E4
function s.atkval(e,c)
	return c:GetBaseAttack()/2
end