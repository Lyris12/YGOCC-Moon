--[[
CODEMAN: Hyperdrive
Card Author: Jake
Original script by: ?
Fixed by: XGlitchy30
]]

local s,id=GetID()
function s.initial_effect(c)
	--atkchange
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(id,0)
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET|EFFECT_FLAG_DELAY)
	e1:HOPT(true)
	e1:SetTarget(s.atktg)
	e1:SetOperation(s.atkop)
	c:RegisterEffect(e1)
	local e1b=e1:Clone()
	e1b:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e1b)
	--search
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(id,1)
	e2:SetCategory(CATEGORIES_SEARCH)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:HOPT(true)
	e2:SetCondition(s.con)
	e2:SetTarget(s.tg)
	e2:SetOperation(s.op)
	c:RegisterEffect(e2)	
end
--E1
function s.atktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and chkc:IsFaceup() and chkc~=c end
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_MZONE,0,1,c) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	local g=Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_MZONE,0,1,1,c)
	Duel.SetCustomOperationInfo(0,CATEGORY_ATKCHANGE,g,#g,0,0,-2,OPINFO_FLAG_HALVE)
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToChain() then
		tc:HalveATK(true,{e:GetHandler(),true})
	end
end

--E2
function s.con(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsAttack(c:GetBaseAttack()) then return false end
	local ATKChangingEffects={EFFECT_UPDATE_ATTACK,EFFECT_SET_ATTACK,EFFECT_SET_ATTACK_FINAL,EFFECT_SWAP_AD}
	for _,etype in ipairs(ATKChangingEffects) do
		for _,ce in ipairs({c:IsHasEffect(etype)}) do
			local rc=ce:GetOwner()
			if rc:IsOriginalSetCard(ARCHE_CODE_JAKE) or rc:IsOriginalType(TYPE_QUICKPLAY) then
				return true
			end
		end
	end
	return false
end
function s.filter(c)
	return c:IsSetCard(ARCHE_CODEMAN) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
function s.tg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.op(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.Search(g)
	end
end