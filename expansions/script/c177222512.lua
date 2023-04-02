--Thunderstorm Sorceress
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	aux.AddOrigBigbangType(c)
	aux.AddBigbangProc(c,aux.FilterEqualFunction(Card.GetVibe,0),1,1,aux.NOT(aux.FilterEqualFunction(Card.GetVibe,0)),1,1)
	--If this card is Bigbang Summoned: You can activate the approriate effect, depending on the monster used as non-Neutral Bigbang Material;
	--● Positive monster: You can target 1 monster your opponent controls; destroy it.
	--● Negative monster: You can target 1 Spell/Trap your opponent controls; destroy it.
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetCode(EFFECT_MATERIAL_CHECK)
	e0:SetValue(s.matcheck)
	c:RegisterEffect(e0)
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetLabelObject(e0)
	e1:SetCountLimit(1,{id,0})
	e1:SetCondition(s.descon)
	e1:SetTarget(s.destg)
	e1:SetOperation(s.desop)
	c:RegisterEffect(e1)
end
function s.matcheck(e,c)
	local positive=c:GetMaterial():FilterCount(aux.FilterEqualFunction(Card.GetVibe,1),nil)
	local negative=c:GetMaterial():FilterCount(aux.FilterEqualFunction(Card.GetVibe,-1),nil)
	local lab=positive-negative
	e:SetLabel(positive-negative+2)
end
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_SPECIAL+340)
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local lab=e:GetLabelObject():GetLabel()
	local loc=LOCATION_MZONE
	if lab==1 then loc=LOCATION_SZONE end
	if chkc then return chkc:IsLocation(loc) end
	if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,0,loc,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_POSCHANGE)
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,0,loc,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
