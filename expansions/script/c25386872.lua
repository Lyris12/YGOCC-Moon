--Steinitz's Bishop
--Script by XGlitchy30
function c25386872.initial_effect(c)
	--spirit return
	aux.EnableSpiritReturn(c,EVENT_SUMMON_SUCCESS,EVENT_SPSUMMON_SUCCESS,EVENT_FLIP_SUMMON_SUCCESS)
	--equip
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(25386872,0))
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1)
	e1:SetTarget(c25386872.eqtg)
	e1:SetOperation(c25386872.eqop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	--limit attack
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_CANNOT_ATTACK)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTargetRange(0,LOCATION_MZONE)
	e3:SetTarget(c25386872.limit_atk_eq)
	c:RegisterEffect(e3)
	--return to hand (OBSOLETE)
	--local e4=Effect.CreateEffect(c)
	--e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	--e4:SetCode(EVENT_SUMMON_SUCCESS)
	--e4:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	--e4:SetOperation(c25386872.regop)
	--c:RegisterEffect(e4)
	--local e5=e4:Clone()
	--e5:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
	--c:RegisterEffect(e5)
	--local e6=e4:Clone()
	--e6:SetCode(EVENT_SPSUMMON_SUCCESS)
	--c:RegisterEffect(e6)
	--equip effect
	local e7=Effect.CreateEffect(c)
	e7:SetType(EFFECT_TYPE_FIELD)
	e7:SetCode(EFFECT_CANNOT_ATTACK)
	e7:SetRange(LOCATION_MZONE)
	e7:SetTargetRange(0,LOCATION_MZONE)
	e7:SetTarget(c25386872.limit_atk_eq)
	local e8=Effect.CreateEffect(c)
	e8:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_GRANT)
	e8:SetRange(LOCATION_SZONE)
	e8:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e8:SetTarget(c25386872.eftg)
	e8:SetLabelObject(e7)
	c:RegisterEffect(e8)
	local e9=Effect.CreateEffect(c)
	e9:SetType(EFFECT_TYPE_EQUIP)
	e9:SetCode(EFFECT_ADD_TYPE)
	e9:SetValue(TYPE_EFFECT)
	c:RegisterEffect(e9)
	local e10=Effect.CreateEffect(c)
	e10:SetType(EFFECT_TYPE_EQUIP)
	e10:SetCode(EFFECT_SPIRIT_MAYNOT_RETURN)
	e10:SetRange(LOCATION_SZONE)
	c:RegisterEffect(e10)
end
--filters
function c25386872.eqfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_MONSTER) and c:IsSetCard(0x63d0)
end
function c25386872.eqcheck(c,eqcard)
	return c==eqcard
end
function c25386872.eqopt(c)
	return (c:IsCode(25386872) or c:IsCode(25386873) or c:IsCode(25386874))
		and not c:IsDisabled()
end
--values
function c25386872.eqlimit(e,c)
	return e:GetOwner()==c
end
--equip
function c25386872.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c25386872.eqfilter(chkc) end
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		and Duel.IsExistingTarget(c25386872.eqfilter,tp,LOCATION_MZONE,0,1,e:GetHandler()) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
	local g=Duel.SelectTarget(tp,c25386872.eqfilter,tp,LOCATION_MZONE,0,1,1,e:GetHandler())
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,g,1,0,0)
end
function c25386872.eqop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if c:IsFaceup() and c:IsRelateToEffect(e) and tc:IsRelateToEffect(e) then
		if not Duel.Equip(tp,tc,c,false) then return end
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_OWNER_RELATE)
		e1:SetCode(EFFECT_EQUIP_LIMIT)
		e1:SetReset(RESET_EVENT+0x1fe0000)
		e1:SetValue(c25386872.eqlimit)
		tc:RegisterEffect(e1)
	end
end
--equip effect/limit attack
function c25386872.eftg(e,c)
	return e:GetHandler():GetEquipTarget()==c
end
function c25386872.limit_atk_eq(e,c)
	local g=e:GetHandler():GetColumnGroup(1,1)
	local ctr=e:GetHandler():GetColumnGroup()
	return g:IsContains(c) and not ctr:IsContains(c)
end