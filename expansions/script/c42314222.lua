--created by Jake, coded by XGlitchy30
--Dawn Blader - Saber
local s,id = GetID()
function s.initial_effect(c)
	aux.AddSetNameMonsterList(c,0x613)
	c:EnableReviveLimit()
	aux.AddXyzProcedure(c,aux.FilterBoolFunction(Card.IsRace,RACE_WARRIOR),4,2)
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DDD)
	e1:HOPT()
	e1:SetCondition(s.thcon)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetCode(EFFECT_MATERIAL_CHECK)
	e0:SetValue(s.valcheck)
	e0:SetLabelObject(e1)
	c:RegisterEffect(e0)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetTarget(s.tglimit)
	e2:SetValue(aux.tgoval)
	c:RegisterEffect(e2)
	c:Ignition(1,CATEGORY_TOHAND,nil,nil,true,nil,aux.DetachSelfCost(),s.thtg2,s.thop2)
	c:SentToGYTrigger(false,2,CATEGORY_DRAW,EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_DDD,true,nil,nil,aux.DrawTarget(),aux.DrawOperation())
end
function s.mfilter(c)
	return c:IsXyzType(TYPE_MONSTER) and c:IsSetCard(0x613)
end
function s.valcheck(e,c)
	local g=c:GetMaterial()
	if g:IsExists(s.mfilter,1,nil) then
		e:GetLabelObject():SetLabel(1)
	else
		e:GetLabelObject():SetLabel(0)
	end
end
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_XYZ) and e:GetLabel()==1
end
function s.filter(c)
	return c:IsMonster() and c:IsSetCard(0x613) and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.filter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.filter,tp,LOCATION_GRAVE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)
	local g=Duel.SelectTarget(tp,s.filter,tp,LOCATION_GRAVE,0,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,#g,tp,LOCATION_GRAVE)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToChain() then
		Duel.Search(tc,tp)
	end
end
function s.tglimit(e,c)
	return c:IsRace(RACE_WARRIOR) and not c:IsCode(id)
end
function s.thfil(c)
	return c:IsMonster() and c:IsRace(RACE_WARRIOR) and c:IsAbleToHand()
end
function s.thtg2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IsExistingMatchingCard(aux.Faceup(Card.IsSetCard),tp,LOCATION_MZONE,0,1,e:GetHandler(),0x613) and Duel.IsExistingMatchingCard(s.thfil,tp,LOCATION_GRAVE,0,1,nil)
	end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE)
end
function s.thop2(e,tp)
	local ct=Duel.GetMatchingGroupCount(aux.Faceup(Card.IsSetCard),tp,LOCATION_MZONE,0,aux.ExceptThis(e),0x613)
	if ct==0 then return end
	Duel.HintMessage(tp,HINTMSG_RTOHAND)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.thfil),tp,LOCATION_GRAVE,0,1,math.min(2,ct),nil)
	if #g>0 then
		Duel.Search(g,tp)
	end
end
