--Steinitz's Knight
--Script by XGlitchy30
function c25386874.initial_effect(c)
	--spirit return
	aux.EnableSpiritReturn(c,EVENT_SUMMON_SUCCESS,EVENT_SPSUMMON_SUCCESS,EVENT_FLIP_SUMMON_SUCCESS)
	--equip
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(25386874,0))
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_GRAVE)
	e1:SetCountLimit(1)
	e1:SetTarget(c25386874.eqtg)
	e1:SetOperation(c25386874.eqop)
	c:RegisterEffect(e1)
	--limit attack
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_CANNOT_ATTACK)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTargetRange(0,LOCATION_MZONE)
	e3:SetTarget(c25386874.limit_atk_eq)
	c:RegisterEffect(e3)
	local efix=Effect.CreateEffect(c)
	efix:SetType(EFFECT_TYPE_FIELD)
	efix:SetRange(LOCATION_MZONE)
	efix:SetOperation(c25386874.atkfix)
	c:RegisterEffect(efix)
	--return to hand
	--local e4=Effect.CreateEffect(c)
	--e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	--e4:SetCode(EVENT_SUMMON_SUCCESS)
	--e4:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	--e4:SetOperation(c25386874.regop)
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
	e7:SetTarget(c25386874.limit_atk_eq)
	local e8=Effect.CreateEffect(c)
	e8:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_GRANT)
	e8:SetRange(LOCATION_SZONE)
	e8:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e8:SetTarget(c25386874.eftg)
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
function c25386874.eqfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_MONSTER) and c:IsSetCard(0x63d0) and not c:IsCode(25386874)
end
function c25386874.eqcheck(c,eqcard)
	return c==eqcard
end
function c25386874.eqopt(c)
	return (c:IsCode(25386872) or c:IsCode(25386873) or c:IsCode(25386874))
		and not c:IsDisabled()
end
--values
function c25386874.eqlimit(e,c)
	return e:GetOwner()==c
end
--equip
function c25386874.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c25386874.eqfilter(chkc) end
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingTarget(c25386874.eqfilter,tp,LOCATION_MZONE,0,1,nil)
			and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
	local g=Duel.SelectTarget(tp,c25386874.eqfilter,tp,LOCATION_MZONE,0,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,g,1,0,0)
end
function c25386874.eqop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and tc:IsRelateToEffect(e) then
		if Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0 then
			if not Duel.Equip(tp,tc,c,false) then return end
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetProperty(EFFECT_FLAG_OWNER_RELATE)
			e1:SetCode(EFFECT_EQUIP_LIMIT)
			e1:SetReset(RESET_EVENT+0x1fe0000)
			e1:SetValue(c25386874.eqlimit)
			tc:RegisterEffect(e1)
		end
	end
end
--equip effect/limit attack
function c25386874.eftg(e,c)
	return e:GetHandler():GetEquipTarget()==c
end
function c25386874.limit_atk_eq(e,c)
	local lr2=e:GetHandler():GetColumnGroup(2,2)
	local lr1=e:GetHandler():GetColumnGroup(1,1)
	local ctr=e:GetHandler():GetColumnGroup()
	return lr2:IsContains(c) and not lr1:IsContains(c) and not ctr:IsContains(c)
end