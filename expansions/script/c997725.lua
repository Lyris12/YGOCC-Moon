--Scripted by IanxWaifu
--Divine-Advent
local s,id=GetID()
function s.initial_effect(c)
	--activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
end
s.list={[0x01]=(0x08),[0x08]=(0x01),[0x02]=(0x04),
				[0x04]=(0x02),[0x10]=(0x20),[0x20]=(0x10)}

function s.confilter(c,tp)
	return c:IsFaceup() and c:IsSetCard(0x12D9)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(s.confilter,tp,LOCATION_MZONE,0,1,nil)
end
function s.spfilter(c,e,tp)
	return c:IsLevelAbove(1) and c:IsSetCard(0x12D9)
end
function s.xyzchk(c,sg,tp)
	return c:IsXyzSummonable(sg,tp) and Duel.GetLocationCountFromEx(tp,tp,sg,c)>0 and c:IsSetCard(0x12D9)
end
function s.spcheck(sg,e,tp,mg)
	return sg:GetClassCount(Card.GetLocation)==#sg and sg:GetClassCount(Card.GetLevel)==1
		and Duel.IsExistingMatchingCard(s.xyzchk,tp,LOCATION_EXTRA,0,1,nil,sg,2,2,tp) and sg:GetClassCount(Card.GetAttribute)==#sg
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local code=c:GetAttribute()
	local tcode=s.list[code]
	if chk==0 then
		local g=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_GRAVE+LOCATION_HAND+LOCATION_DECK,0,nil,tcode,e,tp)
		return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
			and g:CheckSubGroup(s.spcheck,2,2,tp)
			--and aux.SelectUnselectGroup(g,e,tp,2,2,s.spcheck,0)
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,tp,LOCATION_HAND+LOCATION_GRAVE+LOCATION_DECK)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	local c=e:GetHandler()
	local code=c:GetAttribute()
	local tcode=s.list[code]
	local g=Duel.GetMatchingGroup(aux.NecroValleyFilter(s.spfilter),tp,LOCATION_GRAVE+LOCATION_HAND+LOCATION_DECK,0,nil,tcode,e,tp)
	local sg=g:SelectSubGroup(tp,s.spcheck,false,2,2,tp)
--	local sg=aux.SelectUnselectGroup(g,e,tp,2,2,s.spcheck,1,tp,HINTMSG_SPSUMMON)
	if #sg~=2 then return end
	local tc=sg:GetFirst()
	for tc in aux.Next(sg) do
		local e3=Effect.CreateEffect(e:GetHandler())
		e3:SetType(EFFECT_TYPE_FIELD)
		e3:SetRange(LOCATION_MZONE)
		e3:SetCode(EFFECT_EXTRA_MATERIAL)
		e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e3:SetTargetRange(1,0)
		e3:SetValue(s.extram)
		e3:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e3,true)
		tc=sg:GetNext()
	end
	Duel.BreakEffect()
	local xyzg=Duel.GetMatchingGroup(s.xyzchk,tp,LOCATION_EXTRA,0,nil,sg,2,2,tp)
	if #xyzg>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local xyz=xyzg:Select(tp,1,1,nil):GetFirst()
		Duel.XyzSummon(tp,xyz,nil,sg)
	end
end
function s.extram(chk,summon_type,e,...)
	local c=e:GetHandler()
	if chk==0 then
		local tp,sc=...
		if summon_type==SUMMON_TYPE_XYZ then
			return Group.FromCards(c)
		else
			return Group.CreateGroup()
		end
	end
end


