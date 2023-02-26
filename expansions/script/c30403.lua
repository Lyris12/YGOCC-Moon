--Ｚ・ＨＥＲＯ　ドコイマン
--Zero HERO Decoy Man
--Automate ID

local scard,s_id=GetID()

function scard.initial_effect(c)
	Duel.RegisterCustomSetCard(c,30401,30419,CUSTOM_ARCHE_ZERO_HERO)
	Card.IsZHERO=Card.IsZHERO or (function(tc) return (tc:GetCode()>30400 and tc:GetCode()<30420) or (tc:IsSetCard(0x8) and tc:IsCustomSetCard(CUSTOM_ARCHE_ZERO_HERO)) end)
	--to defense
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(s_id,0))
	e1:SetCategory(CATEGORY_POSITION)
	e1:SetType(EFFECT_TYPE_TRIGGER_F+EFFECT_TYPE_SINGLE)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCondition(scard.pocon)
	e1:SetTarget(scard.potg)
	e1:SetOperation(scard.poop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
	c:RegisterEffect(e2)
	local e3=e1:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
	--must be target
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetCode(EFFECT_CANNOT_SELECT_BATTLE_TARGET)
	e4:SetRange(LOCATION_MZONE)
	e4:SetTargetRange(0,LOCATION_MZONE)
	e4:SetCondition(scard.effcon)
	e4:SetValue(scard.atlimit2)
	c:RegisterEffect(e4)
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_FIELD)
	e5:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e5:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_SET_AVAILABLE)
	e5:SetRange(LOCATION_MZONE)
	e5:SetTargetRange(LOCATION_MZONE,0)
	e5:SetCondition(scard.effcon)
	e5:SetTarget(scard.atlimit)
	e5:SetValue(aux.tgoval)
	c:RegisterEffect(e5)
end
function scard.pocon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPosition(POS_FACEUP_DEFENSE)
end
function scard.potg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return true end
	Duel.SetCardOperationInfo(c,CATEGORY_POSITION)
	Duel.SetCustomOperationInfo(0,CATEGORY_POSITION,c,1,c:GetControler(),c:GetLocation(),POS_FACEUP_ATTACK)
end
function scard.poop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c and c:IsRelateToChain() and not c:IsPosition(POS_FACEUP_ATTACK) and Duel.ChangePosition(c,POS_FACEUP_ATTACK)>0 and c:IsPosition(POS_FACEUP_ATTACK) and not c:IsImmuneToEffect(e) then
		local e1=Effect.CreateEffect(c)
		e1:SetDescription(STRING_CANNOT_CHANGE_POSITION)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CANNOT_CHANGE_POSITION)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CLIENT_HINT)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e1)
	end
end

function scard.effconcon(c)
	return c:IsFaceup() and c:IsZHERO()
end
function scard.effcon(e)
	local c=e:GetHandler()
	local tp=e:GetHandlerPlayer()
	return c:IsZHERO() and c:IsFaceup() and c:IsLocation(LOCATION_MZONE) and not Duel.IsExistingMatchingCard(scard.effconcon,tp,LOCATION_MZONE,0,1,c)
end
function scard.atlimit(e,c)
	return c~=e:GetHandler()
end
function scard.atlimit2(e,c)
	return c~=e:GetHandler() and c:IsControler(e:GetHandlerPlayer())
end