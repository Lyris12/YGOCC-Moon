--[[
Cursilver Sword of Endless Pain
Spada Sciagurargento dell'Infinito Dolore
Card Author: Xarc
Scripted by: XGlitchy30
]]

local s,id,o=GetID()
function s.initial_effect(c)
	--Activation
	local e1=Effect.CreateEffect(c)
	e1:Desc(0)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET|EFFECT_FLAG_CONTINUOUS_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_EQUIP_LIMIT)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetValue(1)
	c:RegisterEffect(e2)
	--The equipped monster loses 600 ATK/DEF, also its effects are negated.
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_EQUIP)
	e3:SetCode(EFFECT_UPDATE_ATTACK)
	e3:SetValue(-600)
	c:RegisterEffect(e3)
	e3:UpdateDefenseClone(c)
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_EQUIP)
	e4:SetCode(EFFECT_DISABLE)
	c:RegisterEffect(e4)
	--[[During the Main Phase: You can add 1 "Cursilver" monster from your Deck to your hand, also destroy the equipped monster, and if you do,
	inflict damage to its owner equal to its original Level x 100.]]
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(id,1))
	e5:SetCategory(CATEGORIES_SEARCH|CATEGORY_DESTROY|CATEGORY_DAMAGE)
	e5:SetType(EFFECT_TYPE_IGNITION)
	e5:HOPT()
	e5:SetRange(LOCATION_SZONE)
	e5:SetCondition(aux.IsEquippedCond)
	e5:SetTarget(s.eqtg)
	e5:SetOperation(s.eqop)
	c:RegisterEffect(e5)
	--If this card is in your GY: You can banish 1 other "Cursilver" card from your GY and Tribute 1 card; add this card to your hand.
	local e6=Effect.CreateEffect(c)
	e6:SetDescription(aux.Stringid(id,2))
	e6:SetCategory(CATEGORY_TOHAND)
	e6:SetType(EFFECT_TYPE_IGNITION)
	e6:HOPT()
	e6:SetRange(LOCATION_GRAVE)
	e6:SetCost(s.thcost)
	e6:SetTarget(s.thtg)
	e6:SetOperation(s.thop)
	c:RegisterEffect(e6)
end
--E0
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsFaceup() end
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
	Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToChain() and tc:IsRelateToChain() and tc:IsFaceup() then
		Duel.Equip(tp,c,tc)
	end
end

--E5
function s.thfilter(c)
	return c:IsMonster() and c:IsSetCard(ARCHE_CURSILVER) and c:IsAbleToHand()
end
function s.eqtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil)
	end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	local ec=e:GetHandler():GetEquipTarget()
	if ec then
		Duel.SetCardOperationInfo(ec,CATEGORY_DESTROY)
		if ec:GetOriginalType()&TYPE_MONSTER>0 then
			Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,1,ec:GetOwner(),ec:GetOriginalLevel())
		end
	end
end
function s.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	Duel.HintMessage(tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.Search(g,tp)
	end
	if c:IsRelateToChain() then
		local tc=c:GetEquipTarget()
		if tc and Duel.Destroy(tc,REASON_EFFECT)>0 and tc:IsPreviousLocation(LOCATION_MZONE) and tc:GetOriginalType()&TYPE_MONSTER>0 then
			local lv=tc:GetOriginalLevel()
			if not lv or lv<=0 then return end
			Duel.Damage(tc:GetOwner(),lv*100,REASON_EFFECT)
		end
	end
end

--E6
function s.cfilter(c)
	return c:IsSetCard(ARCHE_CURSILVER) and c:IsAbleToRemoveAsCost()
end
function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_GRAVE,0,1,c)
			and (Duel.CheckReleaseGroup(tp,nil,1,nil) or Duel.IsExistingMatchingCard(Card.IsReleasable,tp,LOCATION_SZONE,0,1,nil))
	end
	local rg=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_GRAVE,0,1,1,c)
	local sg
	local b1=Duel.CheckReleaseGroup(tp,nil,1,nil)
	local b2=Duel.IsExistingMatchingCard(Card.IsReleasable,tp,LOCATION_SZONE,0,1,nil)
	local opt=aux.Option(tp,id-1,2,b1,b2)
	if opt==1 then
		Duel.HintMessage(tp,HINTMSG_RELEASE)
		sg=Duel.SelectMatchingCard(tp,Card.IsReleasable,tp,LOCATION_SZONE,0,1,1,nil)
	else
		sg=Duel.SelectReleaseGroup(tp,nil,1,1,nil)
	end
	Duel.Remove(rg,POS_FACEUP,REASON_COST)
	Duel.Release(sg,REASON_COST)
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		return c:IsAbleToHand()
	end
	Duel.SetCardOperationInfo(c,CATEGORY_TOHAND)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToChain() then
		Duel.Search(c,tp)
	end
end