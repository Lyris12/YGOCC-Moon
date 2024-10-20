--[[
Number iC211: Invernal of the Mirror Scales
Numero iC211: Invernale delle Scaglie Specchio
Card Author: Walrus
Scripted by: XGlitchy30
]]

local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--3 Level 7 DARK monsters
	aux.AddXyzProcedure(c,aux.FilterBoolFunction(Card.IsAttribute,ATTRIBUTE_DARK),7,3)
	--Check Materials
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e0:SetCode(EFFECT_MATERIAL_CHECK)
	e0:SetValue(s.matcheck)
	c:RegisterEffect(e0)
	--[[If this card is Xyz Summoned: You can target 1 DARK monster you control or in your GY; banish all monsters your opponent currently controls with a lower ATK than that monster's.]]
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(id,0)
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY|EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:HOPT()
	e1:SetFunctions(
		aux.XyzSummonedCond,
		nil,
		s.target,
		s.operation
	)
	c:RegisterEffect(e1)
	--[[When your opponent activates a card or effect (Quick Effect): You can detach 1 material from this card; negate the activation, then,
	if you Xyz Summoned this card using "Number i211: Invernal of the Mirror Shield" as material, this card gains 800 ATK/DEF.]]
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(id,1)
	e2:SetCategory(CATEGORY_NEGATE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_CHAINING)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP|EFFECT_FLAG_DAMAGE_CAL)
	e2:SetRange(LOCATION_MZONE)
	e2:HOPT()
	e2:SetCondition(s.discon)
	e2:SetCost(aux.DetachSelfCost())
	e2:SetTarget(s.distg)
	e2:SetOperation(s.disop)
	c:RegisterEffect(e2)
	--[[While this card has materials, your opponent's monsters cannot target other monsters for attacks, except this card, also all other monsters you control are unaffected by your opponent's card effects.]]
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetCode(EFFECT_CANNOT_SELECT_BATTLE_TARGET)
	e4:SetRange(LOCATION_MZONE)
	e4:SetTargetRange(0,LOCATION_MZONE)
	e4:SetCondition(aux.HasXyzMaterialCond)
	e4:SetValue(s.tglimit)
	c:RegisterEffect(e4)
	c:UnaffectedField(UNAFFECTED_OPPO,LOCATION_MZONE,LOCATION_MZONE,0,s.tglimit,aux.HasXyzMaterialCond,EFFECT_FLAG_SET_AVAILABLE)
end
aux.xyz_number[id]=211

function s.matcheck(e,c)
	local g=c:GetMaterial()
	if g and g:IsExists(Card.IsCode,1,nil,id-1) then
		c:RegisterFlagEffect(id,RESET_EVENT|RESETS_STANDARD&~(RESET_TOFIELD|RESET_LEAVE),EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(id,2))
	end
end

--E1
function s.filter(c,g)
	local atk=c:GetAttack()
	return c:IsFaceupEx() and c:IsAttribute(ATTRIBUTE_DARK) and atk>0 and g:IsExists(Card.IsAttackBelow,1,nil,atk-1)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local g=Duel.Group(aux.FaceupFilter(Card.IsAbleToRemove),tp,0,LOCATION_MZONE,nil)
	if chkc then return chkc:IsLocation(LOCATION_MZONE|LOCATION_GRAVE) and chkc:IsControler(tp) and s.filter(chkc,g) end
	if chk==0 then
		return #g>0 and Duel.IsExists(true,s.filter,tp,LOCATION_MZONE|LOCATION_GRAVE,0,1,nil,g)
	end
	local tg=Duel.Select(HINTMSG_TARGET,true,tp,s.filter,tp,LOCATION_MZONE|LOCATION_GRAVE,0,1,1,nil,g)
	local dg=g:Filter(Card.IsAttackBelow,nil,tg:GetFirst():GetAttack()-1)
	Duel.SetCardOperationInfo(dg,CATEGORY_REMOVE)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToChain() and tc:IsMonster() then
		local atk=tc:GetAttack()
		if atk<=0 then return end
		local g=Duel.Group(aux.FaceupFilter(Card.IsAbleToRemove),tp,0,LOCATION_MZONE,nil):Filter(Card.IsAttackBelow,nil,atk-1)
		if #g>0 then
			Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
		end
	end
end

--E2
function s.discon(e,tp,eg,ep,ev,re,r,rp)
	return rp~=tp and not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED) and Duel.IsChainNegatable(ev)
end
function s.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	local c=e:GetHandler()
	if c:IsXyzSummoned() and c:IsSummonPlayer(tp) and c:IsType(TYPE_XYZ) and c:HasFlagEffect(id) then
		e:SetCategory(CATEGORIES_ATKDEF|CATEGORY_NEGATE)
		Duel.SetTargetParam(1)
		Duel.SetCustomOperationInfo(0,CATEGORIES_ATKDEF,c,1,0,0,800)
	else
		e:SetCategory(CATEGORY_NEGATE)
		Duel.SetTargetParam(0)
	end
end
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if Duel.NegateActivation(ev) and Duel.GetTargetParam()==1 and c:IsRelateToChain() and c:IsFaceup() then
		Duel.BreakEffect()
		c:UpdateATKDEF(800,800,true,c)
	end
end

--E4
function s.tglimit(e,c)
	return c~=e:GetHandler()
end