--Dimenticalgia Imperatore, Jinzo
--Script by XGlitchy30
local cid,id=GetID()
function cid.initial_effect(c)
	--spsummon proc
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND+LOCATION_GRAVE)
	e1:SetCondition(cid.sprcon)
	e1:SetOperation(cid.sprop)
	c:RegisterEffect(e1)
	--disable
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_DISABLE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(LOCATION_SZONE,LOCATION_SZONE)
	e2:SetTarget(cid.distg)
	c:RegisterEffect(e2)
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_CHAIN_SOLVING)
	e3:SetRange(LOCATION_MZONE)
	e3:SetOperation(cid.disop)
	c:RegisterEffect(e3)
	--sset
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,0))
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetCode(EVENT_FREE_CHAIN)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1)
	e4:SetHintTiming(0,TIMING_BATTLE_START+TIMING_END_PHASE)
	e4:SetTarget(cid.settg)
	e4:SetOperation(cid.setop)
	c:RegisterEffect(e4)
end
--filters
function cid.resfilter(c,e)
	return (c:IsLocation(LOCATION_HAND) or (c:IsLocation(LOCATION_MZONE) and c:IsFaceup())) and c:IsType(TYPE_MONSTER) and c:IsSetCard(0xf45)
		and c~=e:GetHandler()
end
function cid.relrec(c,tp,sg,mg)
	sg:AddCard(c)
	local res=cid.relgoal(tp,sg) or mg:IsExists(cid.relrec,1,sg,tp,sg,mg)
	sg:RemoveCard(c)
	return res
end
function cid.relgoal(tp,sg)
	Duel.SetSelectedCard(sg)
	if sg:CheckWithSumGreater(Card.GetLevel,8) and Duel.GetMZoneCount(tp,sg)>0 then
		Duel.SetSelectedCard(sg)
		return Duel.CheckReleaseGroupEx(tp,nil,0,nil)
	else return false end
end
function cid.relfilter(c,g)
	return g:IsContains(c)
end
function cid.disfilter(c,tp)
	return c:IsControler(tp) and c:IsFaceup() and c:IsLocation(LOCATION_MZONE) and c:IsType(TYPE_MONSTER) and c:IsSetCard(0xf45)
end
function cid.setfilter(c)
	return c:IsSetCard(0xf45) and c:IsType(TYPE_MONSTER)
end
function cid.dryfilter(c,e)
	return c:IsFaceup() and c:GetLevel()>e:GetHandler():GetOriginalLevel()
end
--spsummon proc
function cid.sprcon(e,c)
	if c==nil then return true end
	if c:IsHasEffect(EFFECT_NECRO_VALLEY) then return false end
	local tp=c:GetControler()
	local mg=Duel.GetReleaseGroup(tp,true):Filter(cid.resfilter,nil,e)
	local sg=Group.CreateGroup()
	return mg:IsExists(cid.relrec,1,nil,tp,sg,mg)
end
function cid.sprop(e,tp,eg,ep,ev,re,r,rp,c)
	local mg=Duel.GetReleaseGroup(tp,true):Filter(cid.resfilter,nil,e)
	local sg=Group.CreateGroup()
	repeat
		local cg=mg:Filter(cid.relrec,sg,tp,sg,mg)
		local g=Duel.SelectReleaseGroupEx(tp,cid.relfilter,1,1,nil,cg)
		sg:Merge(g)
	until cid.relgoal(tp,sg)
	Duel.Release(sg,REASON_COST)
end
--disable
function cid.distg(e,c)
	if not c:IsType(TYPE_SPELL+TYPE_TRAP) then return false end
	return (c:GetCardTargetCount()==0 and c:GetCardTarget():IsExists(cid.disfilter,1,nil,e:GetHandlerPlayer()))
end
function cid.disop(e,tp,eg,ep,ev,re,r,rp)
	if not re:IsActiveType(TYPE_SPELL+TYPE_TRAP) then return end
	if not re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then return end
	local g=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)
	if not g or g:GetCount()==0 then
		local ex,tg,tc=Duel.GetOperationInfo(ev,CATEGORY_DESTROY)
		if ex and tg~=nil and tc+tg:FilterCount(cid.disfilter,nil,tp)-tg:GetCount()>0 then
			Duel.Hint(HINT_CARD,1-tp,id)
			Duel.NegateEffect(ev)
		else
			return
		end
	else
		if g:IsExists(cid.disfilter,1,nil,tp) then
			Duel.Hint(HINT_CARD,1-tp,id)
			Duel.NegateEffect(ev)
		end
	end
end
--sset
function cid.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		and Duel.IsExistingTarget(cid.setfilter,tp,LOCATION_DECK,0,1,nil) 
	end
end
function cid.setop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
	local tc=Duel.SelectMatchingCard(tp,cid.setfilter,tp,LOCATION_DECK,0,1,1,nil):GetFirst()
	if tc then
		local typ=tc:GetOriginalType()
		tc:SetCardData(CARDDATA_TYPE,TYPE_TRAP)
		if tc:IsSSetable() then
			Duel.SSet(tp,tc)
			Duel.ConfirmCards(1-tp,tc)
			tc:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD,EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_SET_AVAILABLE+EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_IGNORE_IMMUNE,1)
			--reset trap status
			local res=Effect.CreateEffect(e:GetHandler())
			res:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
			res:SetCode(EVENT_ADJUST)
			res:SetLabel(typ)
			res:SetLabelObject(tc)
			res:SetCondition(cid.rescon)
			res:SetOperation(cid.reset)
			Duel.RegisterEffect(res,tp)
			--destroy and special summon
			local e3=Effect.CreateEffect(e:GetHandler())
			e3:SetCategory(CATEGORY_DESTROY+CATEGORY_SPECIAL_SUMMON)
			e3:SetType(EFFECT_TYPE_ACTIVATE)
			e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
			e3:SetCode(EVENT_FREE_CHAIN)
			e3:SetCondition(cid.actcon)
			e3:SetCost(cid.actcost)
			e3:SetTarget(cid.acttg)
			e3:SetOperation(cid.act)
			tc:RegisterEffect(e3)
		end
	end
end
--reset trap status
function cid.rescon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetLabelObject():GetFlagEffect(id)<=0
end
function cid.reset(e,tp,eg,ep,ev,re,r,rp)
	e:GetLabelObject():SetCardData(CARDDATA_TYPE,e:GetLabel())
	e:Reset()
end
--destroy and special summon
function cid.actcon(e)
	return e:GetHandler():GetFlagEffect(id)>0
end
function cid.actcost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(1)
	return true
end
function cid.acttg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and cid.dryfilter(chkc,e) end
	if chk==0 then
		if e:GetLabel()==0 then return false end
		e:SetLabel(0)
		return Duel.IsExistingTarget(cid.dryfilter,tp,0,LOCATION_MZONE,1,nil,e) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsPlayerCanSpecialSummonMonster(tp,c:GetOriginalCode(),0xf45,c:GetOriginalType(),c:GetTextAttack(),c:GetTextDefense(),c:GetOriginalLevel(),c:GetOriginalRace(),c:GetOriginalAttribute()) 
	end
	e:SetLabel(0)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectTarget(tp,cid.dryfilter,tp,0,LOCATION_MZONE,1,1,nil,e)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
function cid.act(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) and Duel.Destroy(tc,REASON_EFFECT)~=0 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
	and Duel.IsPlayerCanSpecialSummonMonster(tp,c:GetOriginalCode(),0xf45,c:GetOriginalType(),c:GetTextAttack(),c:GetTextDefense(),c:GetOriginalLevel(),c:GetOriginalRace(),c:GetOriginalAttribute()) then
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_SET_AVAILABLE)
		e1:SetCode(EFFECT_CHANGE_TYPE)
		e1:SetValue(c:GetOriginalType())
		e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TOFIELD)
		c:RegisterEffect(e1)
		Duel.SpecialSummonStep(c,0,tp,tp,true,false,POS_FACEUP)
		Duel.SpecialSummonComplete()
	end
end