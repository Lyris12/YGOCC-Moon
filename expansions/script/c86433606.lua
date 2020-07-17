--Multitask Combinatore
--Script by XGlitchy30
function c86433606.initial_effect(c)
	--equip
	local e0=Effect.CreateEffect(c)
	e0:SetDescription(aux.Stringid(86433606,0))
	e0:SetCategory(CATEGORY_EQUIP)
	e0:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e0:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
	e0:SetCode(EVENT_SPSUMMON_SUCCESS)
	e0:SetRange(LOCATION_MZONE)
	e0:SetCountLimit(1,86433606)
	e0:SetCondition(c86433606.eqcon)
	e0:SetTarget(c86433606.eqtg)
	e0:SetOperation(c86433606.eqop)
	c:RegisterEffect(e0)
	--search
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(86433606,1))
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_GRAVE)
	e1:SetCountLimit(1,80433606)
	e1:SetCost(c86433606.thcost)
	e1:SetTarget(c86433606.thtg)
	e1:SetOperation(c86433606.thop)
	c:RegisterEffect(e1)
	Duel.AddCustomActivityCounter(86433606,ACTIVITY_SPSUMMON,c86433606.counterfilter)
end
--filters
function c86433606.counterfilter(c)
	return c:IsRace(RACE_CYBERSE)
end
function c86433606.cfilter(c,tp)
	return c:IsFaceup() and c:IsControler(1-tp) and c:GetSummonLocation()==LOCATION_EXTRA
end
function c86433606.eqfilter(c)
	return c:IsFaceup() and c:GetSummonLocation()==LOCATION_EXTRA
end
function c86433606.setcodefilter(c)
	return c:IsFaceup() and c:IsSetCard(0x86f)
end
function c86433606.thfilter(c)
	return c:IsSetCard(0x86f) and c:IsAbleToHand() and (c:IsLocation(LOCATION_GRAVE) or c:IsFaceup())
end
--equip
function c86433606.eqcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c86433606.cfilter,1,nil,tp)
end
function c86433606.eqtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		and Duel.IsExistingMatchingCard(c86433606.eqfilter,tp,0,LOCATION_MZONE,1,e:GetHandler()) 
	end
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
function c86433606.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	local ctype={TYPE_TOON,TYPE_SPIRIT,TYPE_UNION,TYPE_DUAL,TYPE_FLIP}
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CARDTYPE)
	local op=Duel.SelectOption(tp,aux.Stringid(86433597,0),aux.Stringid(86433597,1),aux.Stringid(86433597,2),aux.Stringid(86433597,3),aux.Stringid(86433597,4))
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
	local g=Duel.SelectMatchingCard(tp,c86433606.eqfilter,tp,0,LOCATION_MZONE,1,1,e:GetHandler())
	local tc=g:GetFirst()
	if not tc then return end
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 or tc:GetControler()==tp or tc:IsFacedown() then
		Duel.SendtoGrave(c,REASON_EFFECT)
		return
	end
	Duel.Equip(tp,c,tc,true)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_EQUIP_LIMIT)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	e1:SetValue(c86433606.eqlimit)
	e1:SetLabelObject(tc)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_EQUIP)
	e2:SetCode(EFFECT_ADD_TYPE)
	e2:SetValue(ctype[op+1])
	e2:SetReset(RESET_EVENT+RESETS_STANDARD)
	c:RegisterEffect(e2)
	local e2x=e2:Clone()
	e2x:SetCode(EFFECT_CANNOT_ATTACK)
	e2x:SetValue(1)
	c:RegisterEffect(e2x)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_CANNOT_BE_FUSION_MATERIAL)
	e3:SetValue(1)
	c:RegisterEffect(e3)
	local e4=e2:Clone()
	e4:SetCode(EFFECT_CANNOT_BE_SYNCHRO_MATERIAL)
	e4:SetValue(1)
	c:RegisterEffect(e4)
	local e5=e2:Clone()
	e5:SetCode(EFFECT_CANNOT_BE_XYZ_MATERIAL)
	e5:SetValue(1)
	c:RegisterEffect(e5)
	local e6=e2:Clone()
	e6:SetCode(EFFECT_CANNOT_BE_LINK_MATERIAL)
	e6:SetValue(1)
	c:RegisterEffect(e6)
	local e7=e2:Clone()
	e7:SetCode(EFFECT_CANNOT_BE_EVOLUTE_MATERIAL)
	e7:SetValue(1)
	c:RegisterEffect(e7)
	local e8=e2:Clone()
	e8:SetCode(EFFECT_CANNOT_BE_BIGBANG_MATERIAL)
	e8:SetValue(1)
	c:RegisterEffect(e8)
	local e9=e2:Clone()
	e9:SetCode(EFFECT_CANNOT_BE_TIMELEAP_MATERIAL)
	e9:SetValue(1)
	c:RegisterEffect(e9)
	local e10=e2:Clone()
	e10:SetCode(EFFECT_CANNOT_BE_SPACE_MATERIAL)
	e10:SetValue(1)
	c:RegisterEffect(e10)
end
function c86433606.eqlimit(e,c)
	return c==e:GetLabelObject()
end
function c86433606.eqcard(c,cc)
	return c==cc
end
function c86433606.eqcheck(e,tp,eg,ep,ev,re,r,rp)
	local eqg=e:GetHandler():GetEquipGroup()
	return eqg:IsExists(c86433606.eqcard,1,nil,e:GetLabelObject())
end
--search
function c86433606.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return aux.bfgcost(e,tp,eg,ep,ev,re,r,rp,0) and Duel.GetCustomActivityCount(86433606,tp,ACTIVITY_SPSUMMON)==0 end
	aux.bfgcost(e,tp,eg,ep,ev,re,r,rp,1)
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c86433606.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
end
function c86433606.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return not c:IsRace(RACE_CYBERSE)
end
function c86433606.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c86433606.thfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE+LOCATION_REMOVED)
end
function c86433606.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,p,HINTMSG_ATOHAND)
	local sg1=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c86433606.thfilter),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
	if sg1:GetCount()>0 then
		Duel.SendtoHand(sg1,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,sg1)
	end
end