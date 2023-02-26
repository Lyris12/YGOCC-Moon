--Zero HERO Diviner
--Automate ID

local scard,s_id=GetID()

function scard.initial_effect(c)
	Duel.RegisterCustomSetCard(c,30401,30419,CUSTOM_ARCHE_ZERO_HERO)
	Card.IsZHERO=Card.IsZHERO or (function(tc) return (tc:GetCode()>30400 and tc:GetCode()<30420) or (tc:IsSetCard(0x8) and tc:IsCustomSetCard(CUSTOM_ARCHE_ZERO_HERO)) end)
	aux.AddFusionProcFunRep(c,scard.matfilter,2,true)
	c:EnableReviveLimit()
	--spsummon condition
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetCode(EFFECT_SPSUMMON_CONDITION)
	e0:SetValue(scard.splimit)
	c:RegisterEffect(e0)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:Desc(0)
	e1:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_DEFCHANGE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTarget(scard.target)
	e1:SetOperation(scard.activate)
	e1:SetCountLimit(1,s_id)
	c:RegisterEffect(e1)
	--indes
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetTarget(scard.indtg)
	e2:SetValue(1)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	c:RegisterEffect(e3)
end
function scard.matfilter(c)
	if c:IsFusionSetCard(0x8) and c:IsFusionCustomSetCard(CUSTOM_ARCHE_ZERO_HERO) then
		return true
	end
	local codechk=false
	local codes={c:GetFusionCode()}
	for _,code in ipairs(codes) do
		if code>30400 and code<30420 then
			codechk=true
			break
		end
	end
	return codechk
end

function scard.splimit(e,se,sp,st)
	return not e:GetHandler():IsLocation(LOCATION_EXTRA) or aux.fuslimit(e,se,sp,st)
end

function scard.filter(c,tp)
	return c:IsFaceup() and c:IsZHERO() and c:HasAttack() and c:HasDefense() and Duel.IsExistingMatchingCard(scard.statfilter,tp,LOCATION_MZONE,0,1,c,c:GetAttack(),c:GetDefense())
end
function scard.statfilter(c,atk,def)
	return c:IsFaceup() and (c:GetBaseAttack()~=atk or c:GetBaseDefense()~=def)
end
function scard.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and chkc~=c and scard.filter(chkc,tp) end
	if chk==0 then return Duel.IsExistingTarget(scard.filter,tp,LOCATION_MZONE,0,1,c,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	local tg=Duel.SelectTarget(tp,scard.filter,tp,LOCATION_MZONE,0,1,1,c,tp)
	if #tg>0 then
		local tc=tg:GetFirst()
		local g=Duel.GetMatchingGroup(scard.statfilter,tp,LOCATION_MZONE,0,tg,tc:GetAttack(),tc:GetDefense())
		Duel.SetCustomOperationInfo(0,CATEGORY_ATKCHANGE,g,#g,tp,LOCATION_MZONE,0)
		Duel.SetCustomOperationInfo(0,CATEGORY_DEFCHANGE,g,#g,tp,LOCATION_MZONE,0)
	end
end
function scard.activate(e,tp,eg,ep,ev,re,r,rp)
	local sc=Duel.GetFirstTarget()
	if sc and sc:IsRelateToChain() and sc:IsFaceup() then
		local c=e:GetHandler()
		local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE,0,sc)
		local atk,def=sc:GetBaseAttack(),sc:GetBaseDefense()
		for tc in aux.Next(g) do
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_SET_BASE_ATTACK_FINAL)
			e1:SetValue(atk)
			e1:SetReset(RESET_EVENT|RESETS_STANDARD|RESET_PHASE|PHASE_END)
			tc:RegisterEffect(e1)
			local e2=Effect.CreateEffect(c)
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetCode(EFFECT_SET_BASE_DEFENSE_FINAL)
			e2:SetValue(def)
			e2:SetReset(RESET_EVENT|RESETS_STANDARD|RESET_PHASE|PHASE_END)
			tc:RegisterEffect(e2)
		end
	end
end

function scard.indtg(e,c)
	return c:IsZHERO() and c~=e:GetHandler()
end
