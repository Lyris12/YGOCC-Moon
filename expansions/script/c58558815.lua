--Flibberty Hungbalongalogus
--Rivelibbertà Hungbalongalogus
--Scripted by: XGlitchy30

local s,id,o=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsLinkType,TYPE_EFFECT),2,nil,s.lcheck)
	--[[While you control a Set monster, this card cannot be targeted or destroyed by card effects.]]
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e1:SetCondition(s.condition)
	e1:SetValue(1)
	c:RegisterEffect(e1)
	local e1x=e1:Clone()
	e1x:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	c:RegisterEffect(e1x)
	--[[For each Set monster you control, this card gains 1 additional attack during each Battle Phase.]]
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetCode(EFFECT_EXTRA_ATTACK)
	e2:SetRange(LOCATION_MZONE)
	e2:SetValue(s.atkval)
	c:RegisterEffect(e2)
	--[[Once per turn: You can target 1 Set monster you control; flip it face-up, and if you do, this card gains ATK equal to double that monster's DEF, until the next End Phase.]]
	local e3=Effect.CreateEffect(c)
	e3:Desc(0)
	e3:SetCategory(CATEGORY_POSITION|CATEGORY_ATKCHANGE)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetRange(LOCATION_MZONE)
	e3:OPT()
	e3:SetFunctions(nil,nil,s.postg,s.posop)
	c:RegisterEffect(e3)
	--[[When this card declares an attack: You can target 1 Flip monster you control; change it to face-down Defense Position.]]
	local e4=Effect.CreateEffect(c)
	e4:Desc(1)
	e4:SetCategory(CATEGORY_POSITION)
	e4:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_TRIGGER_O)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e4:SetCode(EVENT_ATTACK_ANNOUNCE)
	e4:HOPT()
	e4:SetFunctions(nil,nil,s.postg2,s.posop2)
	c:RegisterEffect(e4)
end
function s.lcheck(g,lc)
	return g:IsExists(Card.IsLinkType,1,nil,TYPE_FLIP)
end

--E1 + E1x 
function s.condition(e)
	return Duel.IsExists(false,Card.IsFacedown,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,nil)
end

--E2
function s.atkval(e)
	return Duel.GetMatchingGroupCount(Card.IsFacedown,e:GetHandlerPlayer(),LOCATION_MZONE,0,nil)
end

--FE3
function s.posfilter(c)
	return c:IsFacedown() and c:IsCanChangePosition()
end
--E3
function s.postg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.posfilter(chkc) end
	if chk==0 then
		return Duel.IsExists(true,s.posfilter,tp,LOCATION_MZONE,0,1,nil)
	end
	local g=Duel.Select(HINTMSG_POSCHANGE,true,tp,s.posfilter,tp,LOCATION_MZONE,0,1,1,nil)
	Duel.SetCardOperationInfo(g,CATEGORY_POSITION)
	local c=e:GetHandler()
	Duel.SetCustomOperationInfo(0,CATEGORY_ATKCHANGE,c,1,c:GetControler(),c:GetLocation())
end
function s.posop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToChain() and tc:IsFacedown() and Duel.Flip(tc,POS_FACEUP)>0 and tc:IsFaceup() and tc:HasDefense()
		and c:IsRelateToChain() and c:IsFaceup() then
		local val=tc:GetDefense()*2
		if val<0 then val=0 end
		local rct=Duel.GetNextPhaseCount(PHASE_END)
		c:UpdateATK(val,{RESET_PHASE|PHASE_END,rct},c)
	end
end

--FE4
function s.posfilter2(c)
	return c:IsFaceup() and c:IsMonster(TYPE_FLIP) and c:IsCanTurnSetGlitchy()
end
--E4
function s.postg2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.posfilter2(chkc) end
	if chk==0 then
		return Duel.IsExists(true,s.posfilter2,tp,LOCATION_MZONE,0,1,nil)
	end
	local g=Duel.Select(HINTMSG_POSCHANGE,true,tp,s.posfilter2,tp,LOCATION_MZONE,0,1,1,nil)
	Duel.SetCardOperationInfo(g,CATEGORY_POSITION)
end
function s.posop2(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToChain() and not tc:IsPosition(POS_FACEDOWN_DEFENSE) then
		Duel.ChangePosition(tc,POS_FACEDOWN_DEFENSE)
	end
end