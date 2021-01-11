--created by LeonDuvall, coded by Lyris
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	aux.AddOrigTimeleapType(c)
	aux.AddTimeleapProc(c,4,function(e,tc) return not Duel.IsExistingMatchingCard(aux.AND(Card.IsFaceup,Card.IsCode),c:GetControler(),LOCATION_MZONE,0,1,nil,id) end,aux.FilterBoolFunction(Card.IsCode,id-5))
	aux.AddCodeList(c,id-5)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCategory(CATEGORY_DEFCHANGE)
	e2:SetHintTiming(TIMING_BATTLE_PHASE)
	e2:SetCondition(function(e) local ph=Duel.GetCurrentPhase() return ph>=PHASE_BATTLE_START and ph<=PHASE_BATTLE and e:GetHandler():GetBattleTarget()~=nil end)
	e2:SetTarget(s.btg)
	e2:SetOperation(s.bop)
	c:RegisterEffect(e2)
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetRange(LOCATION_MZONE)
	e4:SetTargetRange(0,LOCATION_MZONE)
	e4:SetCode(EFFECT_CANNOT_SELECT_BATTLE_TARGET)
	e4:SetValue(s.bvalue)
	c:RegisterEffect(e4)
end
function s.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x1cfd) and c:IsDefenseAbove(1)
end
function s.btg(e,tp,ev,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.filter(chkc) and chkc~=e:GetHandler() end
	if chk==0 then return Duel.IsExistingTarget(s.filter,tp,LOCATION_MZONE,0,1,e:GetHandler()) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	Duel.SelectTarget(tp,s.filter,tp,LOCATION_MZONE,0,1,1,e:GetHandler())
end
function s.bop(e,tp,ev,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and c:IsFaceup() and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_COPY_INHERIT)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE+RESET_PHASE+PHASE_BATTLE)
		e1:SetCode(EFFECT_UPDATE_DEFENSE)
		e1:SetValue(tc:GetDefense())
		c:RegisterEffect(e1)
	end
end
function s.bvalue(e,c)
	return c:IsFaceup() and c:IsSetCard(0xcfd) and not c:IsCode(id)
end
