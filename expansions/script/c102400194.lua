--created & coded by Lyris, art by Ray-V-Xyz of DeviantArt
--サイバー・ドラゴン・ヴァイス
local s,id,o=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsLinkSetCard,0x1093),1,1)
	c:SetSPSummonOnce(id)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetDescription(1109)
	e1:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND+CATEGORY_SPECIAL_SUMMON+CATEGORY_GRAVE_SPSUMMON+CATEGORY_RELEASE)
	e1:SetTarget(s.stg)
	e1:SetOperation(s.sop)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetCategory(CATEGORY_ATKCHANGE)
	e2:SetOperation(s.dop)
	c:RegisterEffect(e2)
end
function s.filter(c,e,tp)
	if not (c:IsAttribute(ATTRIBUTE_DARK+ATTRIBUTE_LIGHT) and c:IsRace(RACE_MACHINE)) then return false end
	if c:IsLocation(LOCATION_GRAVE) then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
	else return c:IsAbleToHand() end
end
function s.stg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_RELEASE,e:GetHandler(),1,0,0)
end
function s.sop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_OPERATECARD)
	local tc=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.filter),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil,e,tp):GetFirst()
	if not tc then return end
	if tc:IsLocation(LOCATION_DECK) then
		if Duel.SendtoHand(tc,nil,REASON_EFFECT)==0 then return end
		Duel.ConfirmCards(1-tp,tc)
	elseif Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)==0 then return end
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.BreakEffect()
		Duel.Release(c,REASON_EFFECT)
	end
end
function s.dop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	local code=aux.SelectFromOptions(tp,{c:IsFaceup(),1113,EFFECT_UPDATE_ATTACK},{true,1116,EFFECT_CANNOT_ATTACK})
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(code)
	local reset=RESET_EVENT+RESETS_STANDARD
	if code==EFFECT_UPDATE_ATTACK then
		e1:SetValue(-500)
		reset=reset+RESET_DISABLE
	else e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE) end
	e1:SetReset(reset)
	c:RegisterEffect(e1)
end
