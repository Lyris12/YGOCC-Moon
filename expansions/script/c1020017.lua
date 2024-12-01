--[[
Galactic CODEMAN: Scale Zero
Card Author: Jake
Original script by: ?
Fixed by: XGlitchy30
]]

local s,id=GetID()
function s.initial_effect(c)
	aux.EnablePendulumAttribute(c)
	--disable
	local p1=Effect.CreateEffect(c)
	p1:SetType(EFFECT_TYPE_FIELD)
	p1:SetCode(EFFECT_DISABLE)
	p1:SetRange(LOCATION_PZONE)
	p1:SetTargetRange(0,LOCATION_PZONE)
	p1:SetCondition(s.discon)
	c:RegisterEffect(p1)
	--spsummon
	local p2=Effect.CreateEffect(c)
	p2:SetDescription(id,0)
	p2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	p2:SetType(EFFECT_TYPE_IGNITION)
	p2:SetRange(LOCATION_PZONE)
	p2:HOPT()
	p2:SetCost(s.spcost)
	p2:SetTarget(s.sptg)
	p2:SetOperation(s.spop)
	c:RegisterEffect(p2)
	-- atk
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(s.val)
	c:RegisterEffect(e1)
	--atk
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(id,1)
	e2:SetCategory(CATEGORY_ATKCHANGE)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:OPT()
	e2:SetTarget(s.target)
	e2:SetOperation(s.operation)
	c:RegisterEffect(e2)
end

--P1
function s.discon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsSetCard,ARCHE_CODEMAN),tp,LOCATION_MZONE,0,1,nil)
end

--P2
function s.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(ARCHE_CODE_JAKE) and c:IsAbleToRemoveAsCost()
end
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.Group(s.cfilter,tp,LOCATION_MZONE,0,nil,tp)
	if chk==0 then return aux.SelectUnselectGroup(g,e,tp,2,2,aux.ChkfMMZ(1),0) end
	local sg=aux.SelectUnselectGroup(g,e,tp,2,2,aux.ChkfMMZ(1),1,tp,HINTMSG_REMOVE)
	if #sg>0 then
		Duel.Remove(sg,POS_FACEUP,REASON_COST)
	end
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return (e:IsCostChecked() or Duel.GetLocationCount(tp,LOCATION_MZONE)>0)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetCardOperationInfo(c,CATEGORY_SPECIAL_SUMMON)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToChain() then return end
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
end

--E1
function s.val(e)
	local base=e:GetHandler():GetBaseAttack()
	local g=Duel.GetMatchingGroup(Card.IsFaceup,0,LOCATION_MZONE,LOCATION_MZONE,e:GetHandler())
	if #g==0 then return 0 end
	local _,atk=g:GetMinGroup(Card.GetAttack)
	return math.floor(0.5 + math.abs(base-atk)/2)
end

--E2
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local g=Duel.GetMatchingGroup(Card.IsFaceup,0,LOCATION_MZONE,LOCATION_MZONE,nil)
	local mg,atk=g:GetMaxGroup(Card.GetAttack)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and chkc:IsFaceup() and not mg:IsContains(chkc) end
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_MZONE,0,1,mg,atk) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	local g=Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_MZONE,0,1,1,mg,atk)
	Duel.SetCustomOperationInfo(0,CATEGORY_ATKCHANGE,g,#g,0,0,math.abs(atk-g:GetFirst():GetAttack()))
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToChain() and tc:IsFaceup() then
		local g=Duel.GetMatchingGroup(Card.IsFaceup,0,LOCATION_MZONE,LOCATION_MZONE,nil)
		local mg,atk=g:GetMaxGroup(Card.GetAttack)
		local val=math.abs(atk-g:GetFirst():GetAttack())
		if val>0 then
			tc:UpdateATK(val,RESET_PHASE|PHASE_END,{e:GetHandler(),true})
		end
	end
end