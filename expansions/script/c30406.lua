--Zero HERO Golem Man
--Automate ID

local scard,s_id=GetID()

function scard.initial_effect(c)
	Duel.RegisterCustomSetCard(c,30401,30419,CUSTOM_ARCHE_ZERO_HERO)
	Card.IsZHERO=Card.IsZHERO or (function(tc) return (tc:GetCode()>30400 and tc:GetCode()<30420) or (tc:IsSetCard(0x8) and tc:IsCustomSetCard(CUSTOM_ARCHE_ZERO_HERO)) end)
	c:EnableReviveLimit()
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsLinkSetCard,0x8),2,2)
	--atkchange
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(s_id,0))
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetTarget(scard.target)
	e1:SetOperation(scard.operation)
	c:RegisterEffect(e1)
	--search
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(s_id,1))
	e2:SetCategory(CATEGORIES_SEARCH)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_BATTLE_DESTROYING)
	e2:SetCondition(aux.bdocon)
	e2:SetTarget(aux.SearchTarget(scard.thfilter))
	e2:SetOperation(aux.SearchOperation(scard.thfilter))
	c:RegisterEffect(e2)
end
function scard.cfilter(c,g)
	return g and g:IsContains(c) and c:IsFaceup() and c:GetAttack()>0
end
function scard.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	local lg=c:GetLinkedGroup()
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and scard.cfilter(chkc,lg) end
	if chk==0 then return Duel.IsExistingTarget(scard.cfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil,lg) end
	local g=Duel.SelectTarget(tp,scard.cfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil,lg)
	Duel.SetCustomOperationInfo(0,CATEGORY_ATKCHANGE,c,1,c:GetControler(),c:GetLocation(),g:GetFirst():GetAttack())
end
function scard.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToChain() and c:IsFaceup() and tc and tc:IsRelateToChain() and scard.cfilter(tc,c:GetLinkedGroup()) then
		local atk=tc:GetAttack()
		if not atk then return end
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(atk)
		e1:SetReset(RESET_EVENT|RESETS_STANDARD|RESET_DISABLE)
		c:RegisterEffect(e1)
	end
end

function scard.thfilter(c)
	return c:IsZHERO() or c:IsCode(97417863,40227329,21686473,76029419,96227613,8662794,93816465,74506079,40854197,70980824,99469936,62070231,94380860,86848580,66403530,2645637,
		30562585,88332693,60162470,85446833,97617181,50005218,17521642,83133491,93014827,1020001,1020003,1020004,1020005,1020006,1020008,1020016,1020017,1020018,1020019,1020033,
		10904014,19182026)
end
