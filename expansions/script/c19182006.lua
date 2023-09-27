--Aircaster Quill
--created by Alastar Rainford, coded by Lyris
--New auxiliaries by XGlitchy30

local s,id=GetID()
function s.initial_effect(c)
	local e0=Effect.CreateEffect(c)
	e0:Desc(2)
	e0:SetCategory(CATEGORY_ATKCHANGE)
	e0:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_TRIGGER_F)
	e0:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e0:SetCode(EVENT_TO_GRAVE)
	e0:SetFunctions(s.atkcon,nil,s.atktg,s.atkop)
	e0:SetReset(RESET_PHASE|PHASE_END)
	local ex=aux.AddAircasterExcavateEffect(c,3,EFFECT_TYPE_QUICK_O,0,id,e0,CATEGORY_ATKCHANGE)
	e0:SetLabelObject(ex)
	aux.AddAircasterEquipEffect(c,1)
	--The first time a monster equipped with this card would be destroyed by battle each turn, it is not destroyed.
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_EQUIP)
	e1:SetCode(EFFECT_INDESTRUCTABLE_COUNT)
	e1:SetCountLimit(1)
	e1:SetCondition(s.econ)
	e1:SetValue(s.valcon)
	c:RegisterEffect(e1)
end
function s.cfilter(c,eid,e)
	local re=c:GetReasonEffect()
	return c:IsMonster() and c:IsRace(RACE_PSYCHIC) and c:IsReason(REASON_EFFECT) and re and re==e and re:GetFieldID()==eid
end
function s.atkfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_PSYCHIC) and c:HasAttack()
end
function s.atkcon(e,tp,eg,ep,ev,re,r,rp)
	if not re then return false end
	local eid=e:GetLabel()
	if not eid then return false end
	return eg:IsExists(s.cfilter,1,nil,eid,e:GetLabelObject())
end
function s.atktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and s.atkfilter(chkc) end
	if chk==0 then return true end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	local g=Duel.SelectTarget(tp,s.atkfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	Duel.SetCustomOperationInfo(0,CATEGORY_ATKCHANGE,g,#g,g:GetFirst():GetControler(),LOCATION_MZONE,{g:GetFirst():GetAttack()*2})
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToChain() and tc:IsFaceup() then
		tc:DoubleATK({RESET_PHASE|PHASE_END,2},e:GetHandler())
	end
end

function s.econ(e)
	return e:GetHandler():IsSpell(TYPE_EQUIP)
end
function s.valcon(e,re,r,rp)
	return r&REASON_BATTLE~=0
end