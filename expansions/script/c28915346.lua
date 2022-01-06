--Divexplorer Unveiler, Wally
local ref,id=GetID()
function ref.initial_effect(c)
	--Summon
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetRange(LOCATION_HAND+LOCATION_REMOVED)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SSET)
	e1:SetTarget(ref.sstg)
	e1:SetOperation(ref.ssop)
	e1:SetCountLimit(1,id)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_MSET)
	c:RegisterEffect(e2)
	--Avarice-Battle
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_TODECK+CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_BATTLE_START)
	e3:SetCondition(ref.descon)
	e3:SetTarget(ref.destg)
	e3:SetOperation(ref.desop)
	e3:SetCountLimit(1,id+1000)
	c:RegisterEffect(e3)
end

function ref.zoneloop(c,e,tp)
	local seq=0
	if c:IsOnField() then seq=c:GetSequence() else seq=c:GetPreviousSequence() end
	--Debug.Message("Sequence: " .. seq)
	if c:IsControler(1-tp) then seq=4-seq end
	--if c:IsLocation(LOCATION_SZONE) then seq=seq-8 end
	local zone = bit.lshift(1,seq)
	local val=bit.bor(e:GetLabel(),zone)
	--Debug.Message("Zone: " .. zone)
	e:SetLabel(val)
end
function ref.sstg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	e:SetLabel(0)
	eg:ForEach(ref.zoneloop,e,tp)
	local zone=e:GetLabel()
	--Debug.Message("Total Zones: " .. zone)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE,tp,LOCATION_REASON_TOFIELD,zone)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP,tp,zone)
	end
	e:SetLabel(zone)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,tp,0)
end
function ref.ssop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local zone=e:GetLabel()
	if Duel.GetLocationCount(tp,LOCATION_MZONE,tp,LOCATION_REASON_TOFIELD,zone)>0 and c:IsRelateToEffect(e) then
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP,zone)
	end
end

function ref.descon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	--local ac=Duel.GetAttacker()
	return bc --and ac==c
end
function ref.descfilter(c)
	return c:IsSetCard(0x72e) and c:IsAbleToDeck()
end
function ref.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingTarget(ref.descfilter,tp,LOCATION_GRAVE,LOCATION_GRAVE,3,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectTarget(tp,ref.descfilter,tp,LOCATION_GRAVE,LOCATION_GRAVE,3,3,nil)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,3,0,0)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,e:GetHandler():GetBattleTarget(),1,0,0)
end
function ref.desop(e,tp,eg,ep,ev,re,r,rp)
	local tg=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	if #tg>0 and Duel.SendtoDeck(tg,nil,2,REASON_EFFECT)>0 then
		local bc=e:GetHandler():GetBattleTarget()
		if bc and bc:IsRelateToBattle() then
			Duel.Destroy(bc,REASON_EFFECT)
		end
	end
end


