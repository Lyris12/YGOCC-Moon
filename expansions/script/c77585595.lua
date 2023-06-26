--Dimenticalgia Imperatore, Jinzo
--Scripted by: XGlitchy30
local s,id=GetID()
function s.initial_effect(c)
	--spsummon proc
	local e1=Effect.CreateEffect(c)
	e1:Desc(0)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND|LOCATION_GRAVE)
	e1:SetCondition(s.hspcon)
	e1:SetTarget(s.hsptg)
	e1:SetOperation(s.hspop)
	c:RegisterEffect(e1)
	--disable
	local e3=Effect.CreateEffect(c)
	e3:Desc(1)
	e3:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_CHAIN_SOLVING)
	e3:SetRange(LOCATION_MZONE)
	e3:SetOperation(s.disop)
	c:RegisterEffect(e3)
	--sset
	local e4=Effect.CreateEffect(c)
	e4:Desc(2)
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetCode(EVENT_FREE_CHAIN)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1)
	e4:SetRelevantTimings()
	e4:SetTarget(s.settg)
	e4:SetOperation(s.setop)
	c:RegisterEffect(e4)
end
--filters
function s.rfilter(c)
	return (c:IsLocation(LOCATION_HAND) or (c:IsLocation(LOCATION_MZONE) and c:IsFaceup())) and c:IsType(TYPE_MONSTER) and c:IsSetCard(0xf45) and c:HasLevel()
end
function s.fselect(g,tp)
	Duel.SetSelectedCard(g)
	return g:CheckWithSumGreater(Card.GetLevel,8) and Duel.GetMZoneCount(tp,g)>0 and Duel.CheckReleaseGroupEx(tp,aux.IsInGroup,#g,nil,g)
end
function s.hspcon(e,c)
	if c==nil then return true end
	if c:IsHasEffect(EFFECT_NECRO_VALLEY) then return false end
	local tp=c:GetControler()
	local rg=Duel.GetReleaseGroup(tp,true):Filter(s.rfilter,c,tp)
	return rg:CheckSubGroup(s.fselect,1,rg:GetCount(),tp)
end
function s.hsptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	local rg=Duel.GetReleaseGroup(tp,true):Filter(s.rfilter,c,tp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
	local sg=rg:SelectSubGroup(tp,s.fselect,true,1,rg:GetCount(),tp)
	if sg then
		sg:KeepAlive()
		e:SetLabelObject(sg)
		return true
	else return false end
end
function s.hspop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	Duel.Release(g,REASON_COST)
end
--spsummon proc
function s.sprcon(e,c)
	if c==nil then return true end
	if c:IsHasEffect(EFFECT_NECRO_VALLEY) then return false end
	local tp=c:GetControler()
	local mg=Duel.GetReleaseGroup(tp,true):Filter(s.resfilter,nil,e)
	local sg=Group.CreateGroup()
	return mg:IsExists(s.relrec,1,nil,tp,sg,mg)
end
function s.sprop(e,tp,eg,ep,ev,re,r,rp,c)
	local mg=Duel.GetReleaseGroup(tp,true):Filter(s.resfilter,nil,e)
	local sg=Group.CreateGroup()
	repeat
		local cg=mg:Filter(s.relrec,sg,tp,sg,mg)
		local g=Duel.SelectReleaseGroupEx(tp,s.relfilter,1,1,nil,cg)
		sg:Merge(g)
	until s.relgoal(tp,sg)
	Duel.Release(sg,REASON_COST)
end
--disable
function s.disfilter(c,tp)
	return c:IsFaceup() and c:IsLocation(LOCATION_MZONE) and c:IsControler(tp) and c:IsSetCard(0xf45)
end
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	if not re:IsActiveType(TYPE_SPELL|TYPE_TRAP) then return end
	local g=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)
	if not re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) or (not g or #g==0) then
		local ex,tg,tc=Duel.GetOperationInfo(ev,CATEGORY_DESTROY)
		if ex and tg~=nil and tc+tg:FilterCount(s.disfilter,nil,tp)-#tg>0 then
			Duel.Hint(HINT_CARD,tp,id)
			Duel.NegateEffect(ev)
		else
			return
		end
	else
		if g:IsExists(s.disfilter,1,nil,tp) then
			Duel.Hint(HINT_CARD,tp,id)
			Duel.NegateEffect(ev)
		end
	end
end
--sset
function s.setfilter(c,h)
	if not (c:IsMonster() and c:IsSetCard(0xf45)) then return false end
	local e1=Effect.CreateEffect(h)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE|EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetCode(EFFECT_MONSTER_SSET)
	e1:SetValue(TYPE_TRAP)
	c:RegisterEffect(e1,true)
	local res=c:IsSSetable()
	e1:Reset()
	return res
end
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.setfilter,tp,LOCATION_DECK,0,1,nil,e:GetHandler()) end
end
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
	local tc=Duel.SelectMatchingCard(tp,s.setfilter,tp,LOCATION_DECK,0,1,1,nil,c):GetFirst()
	if tc then
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE|EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_MONSTER_SSET)
		e1:SetValue(TYPE_TRAP)
		tc:RegisterEffect(e1,true)
		if tc:IsSSetable() then
			Duel.SSet(tp,tc)
			if not tc:IsLocation(LOCATION_SZONE) or not tc:IsFacedown() then return end
			tc:RegisterFlagEffect(id,RESET_EVENT|RESETS_STANDARD,EFFECT_FLAG_CANNOT_DISABLE|EFFECT_FLAG_SET_AVAILABLE|EFFECT_FLAG_UNCOPYABLE|EFFECT_FLAG_IGNORE_IMMUNE,1)
			--destroy and special summon
			local e3=Effect.CreateEffect(c)
			e3:SetCategory(CATEGORY_DESTROY|CATEGORY_SPECIAL_SUMMON)
			e3:SetType(EFFECT_TYPE_ACTIVATE|EFFECT_TYPE_QUICK_O)
			e3:SetProperty(EFFECT_FLAG_CARD_TARGET,EFFECT_FLAG2_ACTIVATE_MONSTER_SZONE)
			e3:SetCode(EVENT_FREE_CHAIN)
			e3:SetRelevantTimings()
			e3:SetCondition(s.actcon)
			e3:SetCost(aux.DummyCost)
			e3:SetTarget(s.acttg)
			e3:SetOperation(s.act)
			tc:RegisterEffect(e3,true)
		end
	end
end
--destroy and special summon
function s.dryfilter(c,lv)
	return c:IsFaceup() and c:IsLevelAbove(lv)
end
function s.actcon(e)
	return e:GetHandler():GetFlagEffect(id)>0
end
function s.acttg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and s.dryfilter(chkc,e) end
	local lv=c:GetOriginalLevel()
	if chk==0 then
		if not e:IsCostChecked() then return false end
		return Duel.IsExistingTarget(s.dryfilter,tp,0,LOCATION_MZONE,1,nil,lv+1) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectTarget(tp,s.dryfilter,tp,0,LOCATION_MZONE,1,1,nil,lv+1)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,#g,0,0)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
function s.act(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToChain() and Duel.Destroy(tc,REASON_EFFECT)~=0 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsRelateToChain() then
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end