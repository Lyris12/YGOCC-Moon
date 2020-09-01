--Dusk Dreamer
local function getID()
	local str=string.match(debug.getinfo(2,'S')['source'],"c%d+%.lua")
	str=string.sub(str,1,string.len(str)-4)
	local cod=_G[str]
	local id=tonumber(string.sub(str,2))
	return id,cod
end
local id,ref=getID()
function ref.initial_effect(c)
	local magick=Effect.CreateEffect(c)
	magick:SetDescription(aux.Stringid(id,0))
	magick:SetCategory(CATEGORY_DAMAGE)
	magick:SetType(EFFECT_TYPE_TRIGGER_O)
	magick:SetProperty(EFFECT_FLAG_DELAY)
	magick:SetCondition(ref.damcon)
	magick:SetTarget(ref.damtg)
	magick:SetOperation(ref.damop)
	aux.AddMagickProcLocation(c,LOCATION_HAND,aux.MagickMatCost,magick,aux.TRUE,1)
	--Mill
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,1))
	e1:SetCategory(CATEGORY_DECKDES)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetTarget(ref.tgtg)
	e1:SetOperation(ref.tgop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	local e3=e1:Clone()
	e3:SetCode(EVENT_FLIP)
	c:RegisterEffect(e3)
	
end
function ref.damcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.CheckChainUniqueness()
end
function ref.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetTargetPlayer(1-tp)
	local dam=Duel.GetCurrentChain()*200
	Duel.SetTargetParam(dam)
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,dam)
end
function ref.damop(e,tp,eg,ep,ev,re,r,rp)
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	Duel.Damage(p,d,REASON_EFFECT)
end

function ref.tgfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsAbleToGrave()
end
function ref.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>=5 end
end
function ref.tgop(e,tp,eg,ep,ev,re,r,rp)
	Duel.ConfirmDecktop(tp,6)
	local g=Duel.GetDecktopGroup(tp,6):Filter(ref.tgfilter,nil)
	if g:GetCount()>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
		local sg1=g:SelectSubGroup(tp,aux.drccheck,false,1,2)
		Duel.SendtoGrave(sg1,REASON_EFFECT+REASON_REVEAL)
	end
	Duel.ShuffleDeck(tp)
end