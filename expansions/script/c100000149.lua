--[[
Melody of the Water Goddess
Melodia della Dea dell'Acqua
Card Author: CeruleanZerry
Scripted by: XGlitchy30
]]

local s,id=GetID()
function s.initial_effect(c)
    --[[Add 1 Drive Monster with 10 or more Energy from your Deck or GY to your hand,
	then, if you added "Sacred Effigy of Water", you can add 1 "Mistress of the Sky" from your Deck or GY to your hand.]]
    local e1=Effect.CreateEffect(c)
	e1:Desc(0)
    e1:SetCategory(CATEGORIES_SEARCH)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:HOPT(true)
    e1:SetFunctions(nil,nil,s.target,s.activate)
    c:RegisterEffect(e1)
	--[[If this card is in your GY, and you control a face-up Fusion Monster that was Fusion Summoned using a Drive Monster(s) as Fusion Material: You can add this card from your GY to your hand.]]
	local e2=Effect.CreateEffect(c)
	e2:Desc(2)
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:HOPT()
	e2:SetCondition(s.thcond)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
	if not s.global_check then
		s.global_check=true
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_FIELD)
		e3:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE|EFFECT_FLAG_SET_AVAILABLE)
		e3:SetCode(EFFECT_MATERIAL_CHECK)
		e3:SetTargetRange(0xff,0xff)
		e3:SetTarget(aux.TargetBoolFunction(Card.IsType,TYPE_FUSION))
		e3:SetValue(s.matcheck)
		Duel.RegisterEffect(e3,0)
	end
end
--E1
function s.filter(c)
	return c:IsMonster(TYPE_DRIVE) and c:IsEnergyAbove(10) and c:IsAbleToHand()
end
function s.filter2(c)
	return c:IsCode(CARD_MISTRESS_OF_THE_SKY) and c:IsAbleToHand()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK|LOCATION_GRAVE,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK|LOCATION_GRAVE)
	Duel.SetPossibleOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK|LOCATION_GRAVE)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,aux.Necro(s.filter),tp,LOCATION_DECK|LOCATION_GRAVE,0,1,1,nil)
	if #g>0 then
		local tc=g:GetFirst()
		if Duel.SearchAndCheck(tc,tp) and tc:IsCode(CARD_SACRED_EFFIGY_OF_WATER) then
			local mg=Duel.GetMatchingGroup(aux.Necro(s.filter2),tp,LOCATION_DECK|LOCATION_GRAVE,0,nil)
			if #mg>0 and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
				Duel.ShuffleHand(tp)
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
				local sg=mg:Select(tp,1,1,nil)
				if #sg>0 then
					Duel.BreakEffect()
					Duel.Search(sg,tp)
				end
			end
		end
	end
end

--E2
function s.cfilter(c)
	return c:IsFaceup() and c:IsMonster(TYPE_FUSION) and c:IsSummonType(SUMMON_TYPE_FUSION) and c:HasFlagEffect(id)
end
function s.thcond(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToHand() end
	Duel.SetCardOperationInfo(c,CATEGORY_TOHAND)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToChain() then
		Duel.Search(c,tp)
	end
end

--E3
function s.matcheck(e,c)
	if c:GetMaterial():IsExists(Card.IsMonster,1,nil,TYPE_DRIVE) then
		c:RegisterFlagEffect(id,RESET_EVENT|RESETS_STANDARD&~(RESET_TOFIELD|RESET_LEAVE),EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(id,3))
	end
end