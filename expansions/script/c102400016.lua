--created & coded by Lyris, art from Yu-Gi-Oh! Duel Monsters Episode 156
--インライトメント・アルティマ ケースト
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetCode(EFFECT_SPSUMMON_CONDITION)
	e0:SetValue(aux.FALSE)
	c:RegisterEffect(e0)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(s.spcon)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_AVOID_BATTLE_DAMAGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetTargetRange(1,0)
	e2:SetCondition(s.condition)
	c:RegisterEffect(e2)
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e4:SetCode(EVENT_BATTLED)
	e4:SetCategory(CATEGORY_TOGRAVE+CATEGORY_REMOVE)
	e4:SetDescription(1100)
	e4:SetTarget(s.sgtg)
	e4:SetOperation(s.sgop)
	c:RegisterEffect(e4)
	c:SetUniqueOnField(1,0,aux.FilterBoolFunction(Card.IsSetCard,0x1da6),LOCATION_MZONE)
end
function s.spfilter(c,g,ft,tp)
	if c:IsControler(tp) and c:GetSequence()<5 then ft=ft+1 end
	return c:IsCode(id-9) and (c:IsControler(tp) or c:IsFaceup())
		and (ft>0 or g:IsExists(s.mzfilter,1,c,tp))
end
function s.mzfilter(c,tp)
	return c:IsControler(tp) and c:GetSequence()<5
end
function s.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	local rg=Duel.GetReleaseGroup(tp):Filter(Card.IsSetCard,nil,0xda6)
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	return ft>-2 and #rg>1 and rg:IsExists(s.spfilter,1,nil,rg,ft,tp)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local rg=Duel.GetReleaseGroup(tp):Filter(Card.IsSetCard,nil,0xda6)
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
	local g1=rg:FilterSelect(tp,s.spfilter,1,1,nil,rg,ft,tp)
	local tc=g1:GetFirst()
	if tc:IsControler(tp) and tc:GetSequence()<5 then ft=ft+1 end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
	if ft>0 then
		local g2=rg:Select(tp,1,1,tc)
		g1:Merge(g2)
	else
		local g2=rg:FilterSelect(tp,s.mzfilter,1,1,tc,tp)
		g1:Merge(g2)
	end
	Duel.Release(g1,REASON_COST)
end
function s.condition(e)
	return Duel.GetAttackTarget()==nil
end
function s.sgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local g=Duel.GetFieldGroup(tp,0,LOCATION_SZONE)
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,g,#g,0,0)
end
function s.sgop(e,tp,eg,ep,ev,re,r,rp)
	local dir=Duel.GetAttackTarget()==nil
	local g=Duel.GetFieldGroup(tp,0,LOCATION_SZONE)
	local ct=Duel.SendtoGrave(g,REASON_EFFECT)
	local sg=Duel.GetOperatedGroup():Filter(aux.NecroValleyFilter(Card.IsLocation),nil,LOCATION_GRAVE)
	if ct>0 and #g>0 and dir then
		Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
	end
end
