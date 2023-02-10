--Unità di Prevenzione del Giorno del Giudizio, Valstasis
--Script by: XGlitchy30

local s,id,o=GetID()
function s.initial_effect(c)
	aux.AddOrigDriveType(c)
	--Drive Effects
	aux.AddDriveProc(c,8)
	local d1=c:DriveEffect(-2,0,CATEGORY_REMOVE+CATEGORY_RECOVER,EFFECT_TYPE_QUICK_O,EFFECT_FLAG_CARD_TARGET,EVENT_FREE_CHAIN,
		nil,
		nil,
		s.target,
		s.operation
	)
	local d2=c:DriveEffect(-10,1,CATEGORIES_SEARCH,EFFECT_TYPE_IGNITION,nil,nil,
		nil,
		nil,
		aux.SearchTarget(s.scfilter,1,LOCATION_DECK+LOCATION_GRAVE),
		aux.SearchOperation(s.scfilter,LOCATION_DECK+LOCATION_GRAVE)
	)
	local d3=c:OverDriveEffect(2,CATEGORY_SPECIAL_SUMMON,EFFECT_TYPE_IGNITION,EFFECT_FLAG_CARD_TARGET,nil,
		nil,
		nil,
		s.sptg,
		s.spop
	)
	--search
	local f=aux.MonsterFilter(Card.IsSetCard,0x660)
	local e1=Effect.CreateEffect(c)
	e1:Desc(5)
	e1:SetCategory(CATEGORIES_SEARCH)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DDD)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:HOPT()
	e1:SetCondition(s.sccon)
	e1:SetTarget(aux.SearchTarget(f))
	e1:SetOperation(aux.SearchOperation(f))
	c:RegisterEffect(e1)
	--draw
	local e2=Effect.CreateEffect(c)
	e2:Desc(6)
	e2:SetCategory(CATEGORY_DRAW)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_ENERGY_CHANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:HOPT()
	e2:SetTarget(aux.DrawTarget())
	e2:SetOperation(aux.DrawOperation())
	c:RegisterEffect(e2)
	--drive summon
	local e3=Effect.CreateEffect(c)
	e3:Desc(7)
	e3:SetCategory(CATEGORY_DESTROY+CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DDD)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:HOPT()
	e3:SetCondition(aux.ByCardEffectCond(1))
	e3:SetTarget(s.sptg2)
	e3:SetOperation(s.spop2)
	c:RegisterEffect(e3)
end
function s.filter(c)
	return c:IsMonster() and c:IsAttribute(ATTRIBUTE_DARK) and c:IsAbleToRemove()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and s.filter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.filter,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectTarget(tp,s.filter,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,#g,PLAYER_ALL,LOCATION_GRAVE)
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,g:GetFirst():GetAttack())
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToChain() and s.filter(tc) and Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)>0 then
		local atk=tc:GetAttack()
		if atk<0 then atk=0 end
		Duel.Recover(tp,atk,REASON_EFFECT)
	end
end

function s.scfilter(c)
	return c:IsMonster(TYPE_DRIVE) and c:IsLevel(4)
end

function s.spfilter(c,e,tp)
	return c:IsMonster(TYPE_DRIVE) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.spfilter(chkc,e,tp) end
	if chk==0 then return Duel.GetMZoneCount(tp)>0 and Duel.IsExistingTarget(s.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectTarget(tp,s.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,#g,tp,LOCATION_GRAVE)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetMZoneCount(tp)<=0 then return end
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToChain() and s.spfilter(tc,e,tp) and Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)~=0 then
		local c=e:GetHandler()
		local e1=Effect.CreateEffect(c)
		e1:Desc(3)
		e1:SetProperty(EFFECT_FLAG_CLIENT_HINT)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
		e1:SetValue(1)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,2)
		tc:RegisterEffect(e1)
		local e2=Effect.CreateEffect(c)
		e2:Desc(4)
		e2:SetProperty(EFFECT_FLAG_CLIENT_HINT)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
		e2:SetValue(1)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,2)
		tc:RegisterEffect(e2)
	end
end

function s.sccon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsSummonType(SUMMON_TYPE_DRIVE) or c:IsSummonLocation(LOCATION_GRAVE)
end

function s.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local g=Duel.GetMatchingGroup(aux.Faceup(Card.IsAttribute),tp,LOCATION_MZONE,LOCATION_MZONE,nil,ATTRIBUTE_DARK)
	if chk==0 then
		return #g>0 and Duel.GetMZoneCount(tp,g)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
	end
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,#g,PLAYER_ALL,LOCATION_MZONE)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,tp,LOCATION_GRAVE)
end
function s.spop2(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(aux.Faceup(Card.IsAttribute),tp,LOCATION_MZONE,LOCATION_MZONE,nil,ATTRIBUTE_DARK)
	if #g>0 and Duel.Destroy(g,REASON_EFFECT)>0 then
		local c=e:GetHandler()
		if c:IsRelateToChain() and Duel.GetMZoneCount(tp)>0 then
			Duel.SpecialSummonRedirect(e,c,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end